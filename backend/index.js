// @ts-nocheck  // <- this line tells VS Code/TypeScript to chill

const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();

const app = express();
app.use(cors());
app.use(express.json());

const db = new sqlite3.Database('./afib.db');

db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS caregivers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT,
      password TEXT,
      name TEXT,
      age INTEGER,
      weight REAL
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS schedules (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      caregiver_id INTEGER,
      pill_name TEXT,
      time TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS intake_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      caregiver_id INTEGER,
      pill_name TEXT,
      expected_time TEXT,
      detected_pill TEXT,
      is_correct INTEGER,
      created_at TEXT
    )
  `);
});

app.post('/caregivers/register', (req, res) => {
  const { email, password, name, age, weight } = req.body;
  db.run(
    `INSERT INTO caregivers (email, password, name, age, weight)
     VALUES (?, ?, ?, ?, ?)`,
    [email, password, name, age, weight],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ id: this.lastID });
    }
  );
});

app.post('/caregivers/:id/schedule', (req, res) => {
  const caregiverId = req.params.id;
  const { pillName, time } = req.body;
  db.run(
    `INSERT INTO schedules (caregiver_id, pill_name, time)
     VALUES (?, ?, ?)`,
    [caregiverId, pillName, time],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ id: this.lastID });
    }
  );
});

app.post('/intake', (req, res) => {
  const { caregiverId, pillName, expectedTime, detectedPill, isCorrect } =
    req.body;

  const createdAt = new Date().toISOString();

  db.run(
    `INSERT INTO intake_events (caregiver_id, pill_name, expected_time, detected_pill, is_correct, created_at)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [caregiverId, pillName, expectedTime, detectedPill, isCorrect ? 1 : 0, createdAt],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });

      const notification =
        !isCorrect ? 'Caregivers have been notified (prototype).' : null;

      res.json({
        id: this.lastID,
        notification,
      });
    }
  );
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Backend listening on http://localhost:${PORT}`);
});
