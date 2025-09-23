// Import the Firebase app and messaging services (version compat)
importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js");

// Your web app's Firebase configuration
// PENTING: Salin objek firebaseConfig dari file web/index.html Anda
const firebaseConfig = {
      apiKey: "AIzaSyBI6qyRmR_zcxn3xNXvkvx2vAM4ojHZeIg",
      authDomain: "lifeline-579f0.firebaseapp.com",
      projectId: "lifeline-579f0",
      storageBucket: "lifeline-579f0.firebasestorage.app",
      messagingSenderId: "616008182162",
      appId: "1:616008182162:web:60fa910e18448c0198394b",
      measurementId: "G-W7Q4PBGX9H"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();