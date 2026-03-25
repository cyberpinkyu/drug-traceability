# API Role Matrix

## Protected Endpoints (`@RequireRole`)

| Method | Path | Roles |
|---|---|---|
| POST | /api/ai/chat | admin, producer, enterprise, institution, regulator, public |
| POST | /api/ai/knowledge/upload | admin, regulator |
| POST | /drug/info | admin, producer |
| PUT | /drug/info/{id} | admin, producer |
| POST | /drug/info/{id} | admin, producer |
| DELETE | /drug/info/{id} | admin |
| PUT | /drug/info/{id}/status | admin, producer |
| GET | /feature/messages | admin, regulator |
| POST | /feature/messages | admin, regulator |
| PUT | /feature/messages/{id}/read | admin, regulator |
| GET | /feature/tickets | admin, regulator |
| POST | /feature/tickets | admin, regulator |
| PUT | /feature/tickets/{id}/assign | admin, regulator |
| PUT | /feature/tickets/{id}/close | admin, regulator |
| GET | /feature/scan/sign | admin, regulator |
| GET | /feature/scan/logs | admin, regulator |
| POST | /feature/data/import/drug | admin, producer, enterprise, institution |
| GET | /regulatory/enforcement | admin, regulator |
| POST | /regulatory/enforcement | admin, regulator |
| PUT | /regulatory/enforcement/{id} | admin, regulator |
| DELETE | /regulatory/enforcement/{id} | admin, regulator |
| GET | /regulatory/inspectors | admin, regulator |
| POST | /regulatory/tasks/dispatch | admin, regulator |
| GET | /regulatory/tasks | admin, regulator |
| GET | /regulatory/tasks/assignee/{assigneeId} | admin, regulator |
| PUT | /regulatory/tasks/{id}/investigation | admin, regulator |
| POST | /regulatory/tasks/{id}/enforcement | admin, regulator |
| GET | /regulatory/stats/circulation | admin, regulator |
| GET | /regulatory/stats/inventory | admin, regulator |
| GET | /regulatory/stats/production | admin, regulator |
| GET | /regulatory/stats/risk | admin, regulator |
| POST | /trace/batch | admin, producer |
| PUT | /trace/batch/{id} | admin, producer |
| POST | /trace/procurement | admin, producer, enterprise, institution |
| POST | /trace/sale | admin, producer, enterprise, institution |
| POST | /trace/usage/record | admin, institution, public |
| POST | /trace/adverse/submit | admin, institution, public, regulator |
| GET | /auth/users | admin, super_admin |
| GET | /auth/users/role/{roleId} | admin, super_admin |
| POST | /auth/users | admin, super_admin |
| PUT | /auth/users/{id} | admin, super_admin |
| DELETE | /auth/users/{id} | admin, super_admin |
| PUT | /auth/users/{id}/status | admin, super_admin |
| GET | /auth/roles | admin, super_admin |

## Notes

- This file is CI-gated by `drug-traceability/scripts/check_role_matrix.py`.
- Any write/read permission change with `@RequireRole` must update this matrix in the same PR.