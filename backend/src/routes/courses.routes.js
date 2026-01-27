const router = require("express").Router();
const { readJson } = require("../utils/file");

router.get("/", (req, res) => {
  const type = (req.query.type || "grado").toLowerCase();
  if (type !== "grado" && type !== "posgrado") {
    return res.status(400).json({ error: "type debe ser grado|posgrado" });
  }

  const data = readJson(type === "grado" ? "courses_grado.json" : "courses_posgrado.json");
  return res.json(data);
});

router.get("/:id", (req, res) => {
  const grado = readJson("courses_grado.json");
  const pos = readJson("courses_posgrado.json");
  const all = [...grado, ...pos];

  const item = all.find(x => x.id === req.params.id);
  if (!item) return res.status(404).json({ error: "not_found" });

  return res.json(item);
});

module.exports = router;
