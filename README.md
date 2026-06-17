# 🍳 Recipe Vault - iOS Native Recipe Manager

[![Swift](https://img.shields.io/badge/Swift-F54A2A?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/swift/)
[![iOS](https://img.shields.io/badge/iOS-000000?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Firebase](https://img.shields.io/badge/Firebase-a08021?style=flat&logo=firebase&logoColor=ffcd34)](https://firebase.google.com/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20Clean-3982CE?style=flat)](https://developer.apple.com/documentation/uikit/architectures)

Recipe Vault is a native iOS application designed for personalized meal management and smart recipe discovery. Developed as a high-standard engineering project, it emphasizes formal software development lifecycle (SDLC) practices, robust database modeling, and clean system architecture.

---

## 📌 Project Context & Metadata

| Attribute | Details |
| :--- | :--- |
| 🎓 Institution | Universitas Ciputra Surabaya |
| 🚀 Academic Timeline | Semester 4 - Final Project for Software Engineering |
| 📅 Development Period | April 2026 - June 2026 |
| 👥 Team Size | 4 Developers |
| 💻 Platform | Native iOS (Swift) |

---

## 🛠️ Engineering & Methodology

This project was built from the ground up prioritizing structural integrity and system reliability:

- SDLC & Documentation: Authored a comprehensive Software Requirements Specification (SRS) document alongside rigorous UML diagrams (Use Case, Sequence, and Class Diagrams) to thoroughly map system boundaries and data mutations before writing a single line of code.
- Quality & Standards: Enforced strict enterprise-grade coding conventions. The development phase was tightly coupled with a formal Test Plan to ensure high code maintainability, minimize regression issues, and guarantee long-term stability.

---

## 🚀 Technical Features & Logic

### 🌐 Third-Party Integration
- TheMealDB API: Seamlessly integrated the API wrapper to fetch, filter, and stream global recipe networks dynamically, providing an expansive and seamless search interface for end-users.

### 🗄️ Relational Data & Persistence Logic
- Core CRUD Engine: Engineered a dependable pipeline for creating, reading, updating, and deleting personalized user-generated recipes and custom dietary collections.
- Complex Relations: Implemented optimized conditional queries to resolve asynchronous relational logic between standard catalog items and dynamic individual user "Favorite" flags.

### ⚙️ System Architecture & Optimization
- MVVM + Clean Architecture: Divided the codebase into strict logical layers (Presentation, Domain, and Data) to maintain decoupled structures and ensure mockable testing environments.
- Binary Storage Optimization: Created a custom Base64 image compression utility that pre-processes user-uploaded media files before shipping them over network sockets, successfully reducing overall payload overhead and optimizing Cloud Firestore storage allocation.

---

## 💻 Tech Stack

- Language: Swift
- UI Framework: UIKit / SwiftUI
- Architecture: MVVM + Clean Architecture
- Database & Backend: Google Cloud Firestore
- Remote API: TheMealDB API REST Endpoints
