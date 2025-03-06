# Chat Application
This is a simple chat application built using Flutter for the frontend and Node.js with MongoDB for the backend. The project is designed to demonstrate the functionality of real-time communication using Socket.io, which is ideal for building chat applications.

## Features
 - Login Screen: Users can log in with their credentials to access the chat application.
 - Connected User Screen: Displays a list of users who are currently online and connected to the application.
 - Chat Screen: A real-time chat interface where users can send and receive messages instantly.
   
## Tech Stack
 - Frontend: Flutter
 - Backend: Node.js
 - Database: MongoDB
 - Real-Time Communication: Socket.io
   
## Installation
 - Prerequisites
 - Node.js (for backend)
 - Flutter SDK (for frontend)
 - MongoDB (for database)
 - Backend Setup (Node.js + MongoDB)
    Clone the repository to your local machine
    cd chat-application/backend
    Install the dependencies for the backend
      npm install
      Set up MongoDB: If you have MongoDB running locally, make sure it is properly configured.
      Alternatively, use MongoDB Atlas or any other MongoDB cloud service.
      Create a .env file in the backend directory and add your MongoDB connection URL:
      MONGO_URI=mongodb://your_mongo_connection_string
      PORT=5000
      Start the backend server: node index.js
      The server will start and listen for incoming connections.

 - Frontend Setup (Flutter)
    Open the project in your Flutter environment:
    cd chat-application/frontend
    Install the necessary dependencies for Flutter: flutter pub get
    Run the Flutter app on your emulator or device: flutter run
    Once the app is running, you will be able to log in, view the connected users, and start chatting in real-time!

## How It Works
Socket.io Integration: The application uses Socket.io for establishing a WebSocket connection between the server and the client. This ensures that messages are delivered in real time.
User Authentication: Users can log in to the chat application, and once authenticated, they will be able to see a list of connected users and engage in real-time conversations.
Real-Time Communication: When a user sends a message, it is broadcast to other connected users via the Socket.io server.
