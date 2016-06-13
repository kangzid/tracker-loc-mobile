# 📱 Staff Tracker - Mobile Application

![Flutter](https://img.shields.io/badge/Flutter-3.5.4-%2302569B?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0-%230175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android)
![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

## 📖 About The Application

**Staff Tracker** is a comprehensive mobile solution designed to streamline workforce management. It enables organizations to monitor employee attendance, track vehicle locations in real-time, and manage operational data efficiently.

Built with **Flutter** and **Dart**, the application offers a seamless cross-platform experience with two distinct roles:
*   **Administrator**: Full control over data oversight, real-time tracking monitoring, and system management.
*   **Employee**: Simplified interface for daily attendance (check-in/out), task viewing, and profile management.

The app focuses on a modern, clean UI/UX with professional error handling and secure session management.

---

## 🛠️ Technology Stack

This project leverages a robust stack of modern technologies:

| Category | Technology | Usage |
|----------|------------|-------|
| **Core Framework** | [Flutter](https://flutter.dev/) | Cross-platform UI development |
| **Language** | [Dart](https://dart.dev/) | Application logic |
| **State Management** | `setState` & `FutureBuilder` | Efficient local state and data fetching |
| **Networking** | `http` | REST API communication |
| **Maps & Location** | `flutter_map` & `geolocator` | OpenStreetMap integration & GPS tracking |
| **Realtime Data** | [Firebase](https://firebase.google.com/) | Live vehicle tracking updates |
| **Local Storage** | `shared_preferences` | Secure token and session storage |
| **UI Components** | `mostly_hugeicons` | Premium, consistent iconography |

---

## 🚀 Key Features

### 🛡️ Administrator Panel
> Centralized control for managers.

*   **Dashboard**: Overview of fleet status, active employees, and daily statistics.
*   **Real-time Tracking**: Monitor vehicle movements live on an interactive map.
*   **Data Management**: CRUD operations for **Employees** and **Vehicles**.
*   **Reports**: View attendance logs and tracking history.
*   **Settings**: Manage account credentials and app preferences.

### 👤 Employee Panel
> Tools for the field workforce.

*   **Attendance System**: GPS-validated Check-in and Check-out.
*   **Task Summary**: View daily assigned tasks and progress.
*   **Profile**: Manage personal information.
*   **Intuitive Navigation**: Easy access to core features via a modern menu grid.

---

## 📸 App Screenshots

| **Login & Splash** | **Admin Dashboard** | **Employee Dashboard** |
|:---:|:---:|:---:|
| <img src="" alt="Login Screen" width="200"/> | <img src="" alt="Admin Home" width="200"/> | <img src="" alt="Employee Home" width="200"/> |
| *Professional Login UI* | *Stats & Management Menu* | *Attendance & Tasks* |

| **Real-time Tracking** | **Data Management** | **Settings & Dialogue** |
|:---:|:---:|:---:|
| <img src="" alt="Tracking Map" width="200"/> | <img src="" alt="Employee List" width="200"/> | <img src="" alt="Logout Dialog" width="200"/> |
| *Live Map View* | *CRUD Operations* | *Custom Dialogs* |

> *Place your screenshots in the `assets/screenshots/` folder and update the `src` links above.*

---

## 📥 Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/tracker-loc-mobile.git
    cd tracker-loc-mobile
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the Application**
    ```bash
    flutter run
    ```
    *Note: Ensure you have an emulator running or a physical device connected.*

---

## 👥 Contributors

| Name | Role | Responsibility |
|------|------|----------------|
| **Zalfyan** | Fullstack Developer | Flutter Mobile App, Backend API, Logic & Integration |
| **Brillian** | Planner & Designer | System Analysis, Database Design (ERD), UI/UX Design |

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
