const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});

let patientQueue = [];
let tokenCounter = 0;
let activeTokenDisplay = "NONE";

function broadcastQueueUpdate() {
    let nextToken = patientQueue.length > 0 ? `TOKEN ${tokenCounter + 1}` : "NONE ACTIVE";
    
    // Crucial: Sending the data structures downstream
    io.emit('queue_update', {
        activeToken: activeTokenDisplay,
        nextToken: nextToken,
        patientQueue: patientQueue 
    });
}

io.on('connection', (socket) => {
    console.log(`🟢 Flutter client connected: ${socket.id}`);
    broadcastQueueUpdate();

    socket.on('add_patient', (data) => {
        console.log(`📝 Added: ${data.name}`);
        patientQueue.push(data.name);
        broadcastQueueUpdate();
    });

    socket.on('call_next', () => {
        if (patientQueue.length > 0) {
            tokenCounter++;
            patientQueue.shift(); 
            activeTokenDisplay = tokenCounter.toString();
        } else {
            activeTokenDisplay = "NONE";
        }
        broadcastQueueUpdate();
    });

    socket.on('reset_queue', () => {
        console.log(`🧹 Queue Flushed`);
        patientQueue = [];
        tokenCounter = 0;
        activeTokenDisplay = "NONE";
        broadcastQueueUpdate();
    });

    socket.on('disconnect', () => {
        console.log(`🔴 Client disconnected: ${socket.id}`);
    });
});

server.listen(3000, () => {
    console.log(`🚀 Queue Server running cleanly on port 3000`);
});