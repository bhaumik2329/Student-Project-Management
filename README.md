# Student Project Management System

## Project Overview

Student Project Management System is a platform designed to streamline the process of managing and accessing capstone projects. It enables faculty to upload and manage past students' group capstone projects, allowing new students to view and reference these projects easily. The system includes functionalities for user management, project uploads, and secure access, all managed via Firebase.

## Features

- **Admin Dashboard:** Manage faculty members and oversee the entire system.
- **Faculty Management:** Faculty can manage students and upload capstone projects.
- **Student Access:** Students can view and download reports of past capstone projects.
- **Project Search:** Search functionality to easily find specific projects.
- **Motivational Quotes:** Display random motivational quotes upon student login.
- **Statistics Dashboard:** Displays the total number of projects, submitted projects, and other key statistics.

## Technologies Used

- **Frontend:** Flutter
- **Backend:** Firebase (Firestore, Firebase Authentication, Firebase Storage)
- **Hosting:** Firebase Hosting
- **State Management:** Provider (suggested for scalability)
- **Version Control:** Git and GitHub

## Requirements Gathering and Market Comparison

Unlike other project management systems, which are often heavy and come with unnecessary features, our system is designed to be simple and specific to capstone project management. It provides just the necessary tools for faculty to upload and manage projects and for students to access them efficiently.

Examples of more complex systems include:
- Jira
- Trello
- Asana

These tools, while powerful, offer a range of features that might not be necessary for educational institutions focused solely on managing capstone projects.

## Project Setup

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- A Firebase project configured with Firestore, Firebase Authentication, and Firebase Storage

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/bhaumik2329/Student-Project-Management.git
   cd Student-Project-Management

   ```
2. **Install dependencies:**
   ```bash
    flutter pub get
   ```
3. **Set up Firebase:**
    1. Create a Firebase project.
    2. Add the `google-services.json` file to the `android/app` directory.
    3. Add the `GoogleService-Info.plist` file to the `ios/Runner` directory.
    4. Ensure Firestore, Firebase Authentication, and Firebase Storage are enabled in your Firebase project.

4. **Deployment Guide**

    ## Hosting on Firebase
    ### Build the project:
    ```bash
    flutter build web
    ```
    ### Deploy to Firebase
    ```bash
    firebase login
    firebase init
    firebase deploy
    ```
    ```bash
    Visit the Firebase Hosting URL provided after deployment
    ```
## Contributing

If you would like to contribute to this project, please fork the repository, create a new branch for your feature or bugfix, and submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.


