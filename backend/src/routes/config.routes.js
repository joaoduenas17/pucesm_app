const router = require("express").Router();
const { readJson } = require("../utils/file");

router.get("/", (req, res) => {
  const config = readJson("config.json");
  res.json(config);
});

module.exports = router;
