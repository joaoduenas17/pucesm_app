const fs = require("fs");
const path = require("path");

function readJson(relPath) {
  const p = path.join(__dirname, "..", "data", relPath);
  const raw = fs.readFileSync(p, "utf-8");
  return JSON.parse(raw);
}

module.exports = { readJson };
