const express = require("express");
const http = require("http");
const socketIo = require("socket.io");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
const server = http.createServer(app);
const io = socketIo(server, { cors: { origin: "*" } });

app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose
  .connect('Connection String', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("Connected to MongoDB Atlas"))
  .catch((err) => console.error("MongoDB Connection Error:", err));

// Message Schema
const messageSchema = new mongoose.Schema({
  sender: String,
  receiver: String,
  message: String,
  timestamp: { type: Date, default: Date.now },
});

const Message = mongoose.model("Message", messageSchema);

// Store Connected Users
const connectedUsers = {};

// Fetch Chat History
app.get("/messages", async (req, res) => {
  const { sender, receiver } = req.query;
  try {
    const messages = await Message.find({
      $or: [
        { sender, receiver },
        { sender: receiver, receiver: sender },
      ],
    }).sort({ timestamp: 1 });
    res.json({ messages });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// WebSocket Connection
io.on("connection", (socket) => {
  console.log("A user connected:", socket.id);

  // User Login
  socket.on("login", (username) => {
    if (connectedUsers[username]) {
      socket.emit("loginError", "Username is already taken!");
    } else {
      connectedUsers[username] = socket.id;
      socket.emit("loginSuccess");

      // Send full user list to the new user
      socket.emit("userList", Object.keys(connectedUsers));

      // Notify all other users of the updated list
      socket.broadcast.emit("userList", Object.keys(connectedUsers));

      console.log(`${username} logged in`);
    }
  });

  // Send Message
  socket.on("sendMessage", async (data) => {
    console.log(`Message from ${data.sender} to ${data.receiver}: ${data.message}`);

    try {
      const newMessage = new Message(data);
      await newMessage.save();

      // Send message to the receiver only
      const receiverSocket = connectedUsers[data.receiver];
      if (receiverSocket) {
        io.to(receiverSocket).emit("receiveMessage", data);
      }

      // Also send it back to the sender
      socket.emit("receiveMessage", data);
    } catch (err) {
      console.error("Error saving message:", err);
    }
  });

  // Handle User Disconnection
  socket.on("disconnect", () => {
    const disconnectedUser = Object.keys(connectedUsers).find(user => connectedUsers[user] === socket.id);
    
    if (disconnectedUser) {
      delete connectedUsers[disconnectedUser];
      io.emit("userList", Object.keys(connectedUsers));
      console.log(`${disconnectedUser} disconnected`);
    }
  });
});

// Start Server
server.listen(5000, () => {
  console.log("Server running on http://localhost:5000");
});
