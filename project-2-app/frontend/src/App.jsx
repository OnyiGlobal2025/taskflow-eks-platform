import { useEffect, useState } from "react";
import "./App.css";

const API_URL = 
  import.meta.env.VITE_API_URL || "http://localhost:5000/api/tasks";

function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");

  const fetchTasks = async () => {
    const response = await fetch(API_URL);
    const data = await response.json();
    setTasks(data);
  };

  const addTask = async (e) => {
    e.preventDefault();

    if (!title.trim()) return;

    await fetch(API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ title })
    });

    setTitle("");
    fetchTasks();
  };

  const deleteTask = async (id) => {
    await fetch(`${API_URL}/${id}`, {
      method: "DELETE"
    });

    fetchTasks();
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  return (
    <main className="app">
      <section className="card">
        <p className="badge">TaskFlow Project 2</p>
        <h1>TaskFlow Dashboard</h1>
        <p className="subtitle">
          A simple task management app prepared for CI/CD, Kubernetes, Helm,
          DevSecOps, and observability.
        </p>

        <form onSubmit={addTask} className="task-form">
          <input
            type="text"
            placeholder="Enter a new task..."
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
          <button type="submit">Add Task</button>
        </form>

        <div className="task-list">
          {tasks.map((task) => (
            <div className="task-item" key={task.id}>
              <span>{task.title}</span>
              <button onClick={() => deleteTask(task.id)}>Delete</button>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}

export default App;