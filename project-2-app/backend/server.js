const express = require("express");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

let tasks = [
  { id: 1, title: "Learn DevOps", completed: false },
  { id: 2, title: "Build TaskFlow Project 2", completed: false }
];

app.get("/", (req, res) => {
  res.send("TaskFlow Backend API is running");
});

app.get("/health", (req, res) => {
  res.status(200).json({ status: "healthy", service: "taskflow-backend" });
});

app.get("/api/tasks", (req, res) => {
  res.json(tasks);
});

app.post("/api/tasks", (req, res) => {
  const { title } = req.body;

  const newTask = {
    id: tasks.length + 1,
    title,
    completed: false
  };

  tasks.push(newTask);
  res.status(201).json(newTask);
});

app.delete("/api/tasks/:id", (req, res) => {
  const id = Number(req.params.id);
  tasks = tasks.filter(task => task.id !== id);
  res.json({ message: "Task deleted successfully" });
});

app.listen(PORT, () => {
  console.log(`TaskFlow backend running on port ${PORT}`);
});