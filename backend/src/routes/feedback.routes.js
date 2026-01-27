const router = require("express").Router();

const memory = [];

router.post("/", (req, res) => {
  const { name = "", email = "", message = "", device = "", version = "" } = req.body || {};
  if (!message.trim()) return res.status(400).json({ error: "message_required" });

  memory.push({
    id: `fb_${Date.now()}`,
    name, email, message, device, version,
    createdAt: new Date().toISOString()
  });

  res.json({ ok: true });
});

router.get("/", (req, res) => res.json(memory));

module.exports = router;
