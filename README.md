# 🤖 Chat Bot (Flutter)

An AI-powered chat application built using **Flutter + BLoC + Clean Architecture**, designed to deliver a ChatGPT-like experience with a scalable architecture for future enhancements.

---

## 🚀 Features

### 💬 AI Chat

* Real-time chat with AI (Gemini API)
* Markdown-supported responses (code blocks, headings, formatted text)
* Clean and responsive chat UI inspired by ChatGPT

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
Domain (Entities + UseCases)
        ↓
Data (Repository + DataSources)
        ↓
Remote API (Dio)
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

⚠️ **Important:** Never commit API keys to public repositories.

---

## ⚠️ Current Limitations

* ❌ No chat history (conversations are not persisted)
* ❌ No user authentication
* ❌ No offline support
* ❌ No multi-device sync

---

## 🔮 Planned Features

### 🧠 Chat History (Upcoming)

* Conversation-based chat system
* Persistent chat storage
* Ability to switch between chats

### ☁️ Backend Integration

Planned integration with:

* Firebase

Using:

* Firebase Authentication → user-based chats
* Cloud Firestore → store conversations
* Firebase Storage (optional) → media support

### 🚀 Future Enhancements

* 🔄 Real-time chat sync across devices
* 🧠 Context-aware conversations (multi-turn memory)
* 🔍 Chat search & filtering
* 🖼️ Image/file support
* ⚡ Streaming response (typing effect)

---

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
