const express = require("express");
const cors = require("cors");

const healthRoutes = require("./src/routes/health.routes");
const coursesRoutes = require("./src/routes/courses.routes");
const newsRoutes = require("./src/routes/news.routes");
const configRoutes = require("./src/routes/config.routes");
const feedbackRoutes = require("./src/routes/feedback.routes");

const app = express();

app.use(express.json({ limit: "1mb" }));
app.use(cors());

app.use("/api/health", healthRoutes);
app.use("/api/courses", coursesRoutes);
app.use("/api/news", newsRoutes);
app.use("/api/config", configRoutes);
app.use("/api/feedback", feedbackRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`✅ Backend running on http://localhost:${PORT}`));
