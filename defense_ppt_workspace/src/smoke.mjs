const {
  Presentation,
  PresentationFile,
  column,
  text,
  shape,
  fill,
  hug,
  fixed,
} = await import("@oai/artifact-tool");

const presentation = Presentation.create({
  slideSize: { width: 1920, height: 1080 },
});

const slide = presentation.slides.add();
slide.compose(
  column(
    { name: "root", width: fill, height: fill, padding: 80, gap: 30 },
    [
      shape({ name: "bar", shape: "rect", width: fixed(220), height: fixed(12), fill: "#2563EB" }),
      text("药品追溯监管系统", {
        name: "title",
        width: fill,
        height: hug,
        style: { fontSize: 72, bold: true, color: "#0F172A", fontFace: "Microsoft YaHei" },
      }),
    ],
  ),
  { frame: { left: 0, top: 0, width: 1920, height: 1080 }, baseUnit: 8 },
);

const pptxBlob = await PresentationFile.exportPptx(presentation);
await pptxBlob.save("output/smoke.pptx");
const pngBlob = await presentation.export({ slide, format: "png" });
const fs = await import("node:fs/promises");
await fs.writeFile("scratch/smoke.png", Buffer.from(await pngBlob.arrayBuffer()));
