#!/usr/bin/env python3
import argparse
import pathlib
import re
import sys

HTTP_METHODS = {"GET", "POST", "PUT", "DELETE", "PATCH"}


def normalize_path(base: str, sub: str) -> str:
    base = (base or "").strip()
    sub = (sub or "").strip()
    if not base:
        path = sub
    elif not sub:
        path = base
    else:
        path = "/".join([base.rstrip("/"), sub.lstrip("/")])
    if not path.startswith("/"):
        path = "/" + path
    path = re.sub(r"/+", "/", path)
    return path


def parse_roles(raw: str):
    roles = re.findall(r'"([^"]+)"', raw)
    return sorted(set(r.strip() for r in roles if r.strip()))


def parse_controller_file(path: pathlib.Path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    class_base = ""
    seen_class = False

    pending_roles = None
    pending_routes = []
    protected = []

    req_map_re = re.compile(r"@RequestMapping\(\s*\"([^\"]*)\"\s*\)")
    role_re = re.compile(r"@RequireRole\(\{([^}]*)\}\)")
    route_re = re.compile(r"@(Get|Post|Put|Delete|Patch)Mapping\(\s*\"([^\"]*)\"\s*\)")
    method_sig_re = re.compile(r"^public\s+")

    for line in lines:
        stripped = line.strip()

        if not seen_class:
            m_base = req_map_re.search(stripped)
            if m_base:
                class_base = m_base.group(1)
            if " class " in f" {stripped} ":
                seen_class = True

        m_role = role_re.search(stripped)
        if m_role:
            pending_roles = parse_roles(m_role.group(1))
            continue

        m_route = route_re.search(stripped)
        if m_route:
            method = m_route.group(1).upper()
            sub_path = m_route.group(2)
            pending_routes.append((method, normalize_path(class_base, sub_path)))
            continue

        if pending_routes and method_sig_re.search(stripped):
            if pending_roles:
                for method, full_path in pending_routes:
                    protected.append((method, full_path, tuple(pending_roles)))
            pending_routes = []
            pending_roles = None

    return protected


def parse_protected_from_code(controllers_dir: pathlib.Path):
    items = []
    for fp in sorted(controllers_dir.glob("*.java")):
        items.extend(parse_controller_file(fp))

    mapping = {}
    for method, path, roles in items:
        mapping[(method, path)] = set(roles)
    return mapping


def clean_roles_cell(cell: str):
    no_note = re.sub(r"\(.*?\)", "", cell)
    roles = [r.strip() for r in no_note.split(",") if r.strip()]
    return set(roles)


def parse_matrix_doc(matrix_path: pathlib.Path):
    mapping = {}
    for raw in matrix_path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line.startswith("|"):
            continue
        if line.startswith("|---"):
            continue
        parts = [p.strip() for p in line.strip("|").split("|")]
        if len(parts) < 3:
            continue
        if parts[0].lower() == "method":
            continue

        methods = [m.strip().upper() for m in parts[0].split("/") if m.strip()]
        path = parts[1].strip()
        roles = clean_roles_cell(parts[2])

        if not path.startswith("/"):
            continue

        for m in methods:
            if m in HTTP_METHODS:
                mapping[(m, path)] = roles
    return mapping


def main():
    parser = argparse.ArgumentParser(description="Check @RequireRole coverage against role matrix doc")
    parser.add_argument("--controllers", required=True, help="controllers directory")
    parser.add_argument("--matrix", required=True, help="matrix markdown file")
    args = parser.parse_args()

    controllers_dir = pathlib.Path(args.controllers)
    matrix_path = pathlib.Path(args.matrix)

    if not controllers_dir.exists():
        print(f"controllers dir not found: {controllers_dir}")
        return 2
    if not matrix_path.exists():
        print(f"matrix file not found: {matrix_path}")
        return 2

    code = parse_protected_from_code(controllers_dir)
    doc = parse_matrix_doc(matrix_path)

    missing = []
    mismatch = []
    extra = []

    for key, code_roles in sorted(code.items()):
        if key not in doc:
            missing.append((key, code_roles))
        else:
            doc_roles = doc[key]
            if code_roles != doc_roles:
                mismatch.append((key, code_roles, doc_roles))

    for key, doc_roles in sorted(doc.items()):
        if key not in code:
            extra.append((key, doc_roles))

    if not (missing or mismatch or extra):
        print(f"ROLE_MATRIX_CHECK: OK ({len(code)} protected endpoints)")
        return 0

    print("ROLE_MATRIX_CHECK: FAILED")

    if missing:
        print("\n[Missing in doc]")
        for (method, path), roles in missing:
            print(f"- {method} {path} :: {','.join(sorted(roles))}")

    if mismatch:
        print("\n[Role mismatch]")
        for (method, path), code_roles, doc_roles in mismatch:
            print(f"- {method} {path} :: code={','.join(sorted(code_roles))} doc={','.join(sorted(doc_roles))}")

    if extra:
        print("\n[Extra in doc]")
        for (method, path), roles in extra:
            print(f"- {method} {path} :: {','.join(sorted(roles))}")

    return 1


if __name__ == "__main__":
    sys.exit(main())