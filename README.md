# SigNova

SigNova is a Flutter-based application that bridges the communication gap between Deaf and hearing individuals using sign language translation powered by AI and Unity.

## Features

- 🧑‍🦽 Text-to-Sign translation using a 3D Unity avatar.
- 📷 Sign-to-Text translation using computer vision.
- 🤖 AI-powered translation pipeline.
- 💬 Chat interface with translation support.

---

## Prerequisites

Before running the project, make sure you have installed:

- Flutter SDK
- Android Studio / VS Code
- Python 3.x
- Git

---

## Project Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd sigNova
```

### 2. Install Flutter packages

```bash
flutter pub get
```

### 3. Download the UnityLibrary

The UnityLibrary is not included in this repository because of its large size.

Install the required Python package:

```bash
pip install gdown
```

Run the download script:

```bash
python scripts/download_unity.py
```

The script will:

- Download the UnityLibrary from Google Drive.
- Extract it automatically.
- Place it inside:

```
android/UnityLibrary
```

### 4. Run the project

```bash
flutter run
```

## Notes

- Do not commit the `android/UnityLibrary` directory.
- If the UnityLibrary already exists, the download script will skip downloading it.
- Ensure you have an internet connection when running the setup script for the first time.
