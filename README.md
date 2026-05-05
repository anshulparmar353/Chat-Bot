# 🤖 Chat Bot (Flutter)

> 🚀 A production-ready ChatGPT-like AI chat app built with Flutter, Firebase, and Clean Architecture.
---

## 🚀 Features

### 💬 AI Chat

* Real-time AI chat (Gemini API)
* Context-aware conversation (multi-turn memory)
* ChatGPT-like typing animation (character streaming)
* Markdown-supported responses (code blocks, headings, formatted text)

---

### 📚 Chat History (NEW)

* Multiple chat sessions (like ChatGPT)
* Switch between conversations
* Chat history stored in Firebase Firestore
* Auto-generated conversation titles

---

### 🔐 Authentication (NEW)

* Firebase Anonymous Authentication
* User-based chat history

---

### ⚠️ Smart Error Handling (NEW)

* Errors shown as bot messages inside chat
* Handles:
  * No internet
  * Timeout
  * Server errors
  * API failures

### ⚡ Performance & UX

* Efficient API handling using Dio
* Smooth scrolling and message rendering
* Structured error handling with user-friendly responses

---

## 🧱 Architecture

This project follows **Clean Architecture** principles to ensure scalability and maintainability:

```text
Presentation (UI + BLoC)
        ↓
Domain (Entities + Repositories)
        ↓
Data (Repository + DataSources)
        ↓
Remote API (Dio) + Firebase (Firestore + Auth)
```

### 🔹 Tech Stack

* **Flutter**
* **BLoC (flutter_bloc)**
* **Dio (Networking)**
* **get_it (Dependency Injection)**
* **Markdown Rendering (flutter_markdown / gpt_markdown)**

---

## 📁 Folder Structure

```text
lib/
├── core/
│   ├── error/
│   ├── network/
│   ├── services/
│   ├── utils/
│   └── di/
│
├── features/
│   └── chat_bot/
│       ├── data/
│       │   ├── models/
│       │   ├── datasources/
│       │   └── repositories/
│       │
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       │
│       ├── presentation/
│       │   ├── bloc/
│       │   ├── screens/
│       │   └── widgets/
│
└── main.dart
```

## 🧠 How It Works

1. User sends a message  
2. Message is stored in Firebase (Firestore)  
3. Full conversation history is sent to AI (Gemini API)  
4. AI generates a context-aware response  
5. Response is streamed with typing animation  
6. Messages are saved for future conversations  

---

## 🔮 Future Improvements

* 🔁 Retry failed messages
* 📡 Real-time streaming (API-level streaming)
* 🌐 Offline support
* 🔍 Chat search & filtering
* 🧠 AI-generated smart titles

---

## ⚙️ Getting Started

### 1. Clone Repository

```bash
git clone https://github.com/your-username/chat_bot.git
cd chat_bot
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run App

```bash
flutter run
```

---

## 🔐 API Setup

This project uses an AI API (e.g., Gemini).

👉 Add your API key in:

```text
core/network/api_endpoints.dart
```

## 📸 UI Highlights

* ChatGPT-style message layout
* User messages → right aligned
* Bot responses → markdown-rendered

---

## 🧑‍💻 Author

**Anshul Parmar**

* GitHub: https://github.com/anshulparmar353
* LinkedIn: https://www.linkedin.com/in/anshulparmar353

---

## ⭐ Contributing

Contributions are welcome. Fork the repository and submit a pull request.

---
