## 📦 Release Information

| Item | Details |
|------|--------|
| **Application** | Staff Tracker |
| **Version** | v1.1.0 |
| **Build Number** | +2 |
| **Release Type** | Feature Update & UI Refinement |
| **Flutter SDK** | 3.5.4 |
| **Release Date** | 2025-12-27 |

---

## ✨ What's New

| Category | Description |
|--------|------------|
| UI | **Modernized Admin Pages**: Updated `EmployeePage` & `VehiclePage` with consistent `CustomAppBar` and premium `HugeIcons`. |
| Feature | **Session Expiry Handling**: Added automatic session validation in Admin & Employee Dashboards with a "Sesi Berakhir" dialog redirecting to login. |
| UX | **Navigation**: Enabled "Back Button" logic in Admin sub-pages for better navigation flow. |
| UX | **Error Handling**: Replaced raw login error messages with professional `CustomConfirmationDialog` popups. |
| UX | **User-Friendly Errors**: Automatically parsing technical errors (e.g., "ClientException") into simple messages like "Koneksi bermasalah". |

---

## 🐛 Bug Fixes

| Issue | Status |
|------|--------|
| Logout Dialog | Fixed issue where "TIDAK" button was hidden (now shows both options correctly). |
| Async Gaps | Resolved multiple `use_build_context_synchronously` lints potential crashes during navigation. |
| Icon Errors | Fixed undefined/broken icon references in Admin panels. |

---

## 🔧 Improvements

| Area | Details |
|------|--------|
| Code Quality | Cleaned up lint warnings and enforced stricter static analysis constraints. |
| Architecture | Enhanced `CustomConfirmationDialog` to support both Alert (1 button) and Confirmation (2 buttons) modes. |
| Performance | Optimized state checks (`mounted`) before UI updates in async operations. |

---

## 📱 APK Downloads

| File Name | Architecture | Size | Recommended For |
|----------|-------------|------|-----------------|
| `staff-tracker-v1.1.0-arm64-v8a.apk` | ARM 64-bit | ~22 MB | Most modern Android devices |
| `staff-tracker-v1.1.0-armeabi-v7a.apk` | ARM 32-bit | ~21.7 MB | Older Android devices |
| `staff-tracker-v1.1.0-x86_64.apk` | x86_64 | ~22.1 MB | Emulator / Intel-based devices |

---

## ℹ️ Installation Notes

| Info | Description |
|-----|-------------|
| Minimum Android | Android 8.0 (API 26) |
| Installation | Enable **Install unknown apps** |
| Breaking Changes | None |

---

If you are unsure which APK to download, choose **ARM 64-bit** , it supports most Android devices.

Thank you for using **Staff Tracker** 🙌  
For feedback or bug reports, please open an issue in this repository.

---

## 🤝 Acknowledgements

We would like to sincerely thank the team involved in the development of **Staff Tracker**.  
This release would not have been possible without the collaboration, dedication, and continuous effort from everyone who contributed.

| Contributor | Role & Responsibilities |
|-----|-------------|
| **Zalfyan** | **Fullstack Developer** (Flutter & Backend) <br> Implementasi logika aplikasi, integrasi API, session handling, dan modernisasi UI Admin. |
| **Brillian** | **Project Planner & Designer** <br> Perencanaan proyek, perancangan ERD (Database), dan desain UI/UX. |

We appreciate the teamwork and commitment that helped deliver a more stable and improved version of **Staff Tracker** 💝  
Thank you for your valuable contributions.
