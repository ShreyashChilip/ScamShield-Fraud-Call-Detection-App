# ScamShield: Fraud Call Detection App

A cross-platform mobile application developed using Flutter to detect and block fraudulent calls, enhancing user security and privacy.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [License](#license)

## Overview

ScamShield is a mobile application designed to identify and block fraudulent calls. Built with Flutter, it supports multiple platforms including Android, iOS, Windows, macOS, Linux, and web browsers.

## Features

- **Cross-Platform Support:** Runs seamlessly on Android, iOS, Windows, macOS, Linux, and web platforms.
- **Fraudulent Call Detection:** Identifies potential scam calls and alerts the user.
- **Call Blocking:** Provides options to block identified fraudulent numbers.
- **User-Friendly Interface:** Simple and intuitive UI for ease of use.

## Project Structure

```
ScamShield-Fraud-Call-Detection-App/
├── android/
├── assets/
├── ios/
├── lib/
│   ├── main.dart
│   └── ...
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── .gitignore
├── .metadata
├── README.md
├── analysis_options.yaml
├── pubspec.lock
└── pubspec.yaml
```

- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`: Platform-specific directories containing necessary files for respective platforms.
- `assets/`: Directory for storing assets like images, fonts, etc.
- `lib/`: Contains the main Dart code for the application.
  - `main.dart`: Entry point of the application.
- `test/`: Directory for unit and widget tests.
- `.gitignore`: Specifies files and directories to be ignored by Git.
- `.metadata`: Metadata for the Flutter project.
- `README.md`: This file.
- `analysis_options.yaml`: Configuration for Dart analysis options.
- `pubspec.lock`: Lock file for package versions.
- `pubspec.yaml`: Contains project dependencies and metadata.

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ShreyashChilip/ScamShield-Fraud-Call-Detection-App.git
   ```
2. **Navigate to the Project Directory:**
   ```bash
   cd ScamShield-Fraud-Call-Detection-App
   ```
3. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the Application:**
   ```bash
   flutter run
   ```

## Usage

- **Detecting Fraudulent Calls:** The app will notify users when an incoming call is suspected to be fraudulent.
- **Provides speaker diarization:** The app provides analysis for every speaker in the phone call, and percent based prediction and further suggestion for each speaker.

## Dependencies

- **Flutter SDK:** Ensure you have the latest version of Flutter installed. [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- **Dart Packages:** All required Dart packages are listed in the `pubspec.yaml` file. Use `flutter pub get` to install them.

## License

This project is licensed under the [MIT License](LICENSE).
