const router = require("express").Router();
const { readJson } = require("../utils/file");

router.get("/", (req, res) => {
  const items = readJson("news.json");
  res.json(items);
});

router.get("/:id", (req, res) => {
  const items = readJson("news.json");
  const it = items.find(x => x.id === req.params.id);
  if (!it) return res.status(404).json({ error: "not_found" });
  res.json(it);
});

module.exports = router;
