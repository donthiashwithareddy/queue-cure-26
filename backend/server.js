const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

let patientsQueue = [];

app.get('/', (req, res) => {
  res.send({ status: "Queue Cure Server Engine Live", activePatients: patientsQueue.length });
});

io.on('connection', (socket) => {
  console.log(`Pipeline handshake established: Client connected -> ${socket.id}`);

  socket.emit('queue_update', patientsQueue);

  socket.on('add_patient', (patientName) => {
    if (!patientName || patientName.trim() === "") return;
    
    const newPatient = {
      id: Date.now().toString(),
      name: patientName.trim(),
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    };
    
    patientsQueue.push(newPatient);
    console.log(`Queue Registration Added: ${newPatient.name}`);
    
    io.emit('queue_update', patientsQueue);
  });

  socket.on('call_next', () => {
    if (patientsQueue.length > 0) {
      const servedPatient = patientsQueue.shift();
      console.log(`Token Transition: Now Serving -> ${servedPatient.name}`);
      
      io.emit('queue_update', patientsQueue);
    }
  });

  // 4. Clean up connection pipelines upon client closeouts
  socket.on('disconnect', () => {
    console.log(`Pipeline closed down: Client disconnected -> ${socket.id}`);
  });
});
const PORT = process.env.PORT || 3000;

server.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 System Engine initialized. Listening on Cloud Port: ${PORT}`);
});
