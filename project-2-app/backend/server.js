const express = require("express");
const cors = require("cors");
const client = require("prom-client");

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Prometheus metrics setup
const register = new client.Registry();

client.collectDefaultMetrics({
  register,
});

// In-memory task data
let tasks = [
  { id: 1, title: "Learn DevOps", completed: false },
  { id: 2, title: "Build TaskFlow Project 2", completed: false },
];

// Root route
app.get("/", (req, res) => {
  res.send("TaskFlow Backend API is running");
});

// Health check route
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    service: "taskflow-backend",
  });
});

// Prometheus metrics route
app.get("/metrics", async (req, res) => {
  try {
    res.set("Content-Type", register.contentType);
    res.end(await register.metrics());
  } catch (error) {
    res.status(500).end(error.message);
  }
});

// Get all tasks
app.get("/api/tasks", (req, res) => {
  res.json(tasks);
});

// Create new task
app.post("/api/tasks", (req, res) => {
  const { title } = req.body;

  if (!title) {
    return res.status(400).json({
      message: "Task title is required",
    });
  }

  const newTask = {
    id: tasks.length + 1,
    title,
    completed: false,
  };

  tasks.push(newTask);
  res.status(201).json(newTask);
});

// Delete task
app.delete("/api/tasks/:id", (req, res) => {
  const id = Number(req.params.id);

  const taskExists = tasks.some((task) => task.id === id);

  if (!taskExists) {
    return res.status(404).json({
      message: "Task not found",
    });
  }

  tasks = tasks.filter((task) => task.id !== id);

  res.json({
    message: "Task deleted successfully",
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`TaskFlow backend running on port ${PORT}`);
});