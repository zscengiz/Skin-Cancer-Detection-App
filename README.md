# Skin Cancer Detection App

Skin Cancer Detection App is a mobile-first application designed to assist users in the early detection of skin cancer.  
The project is structured with a FastAPI backend and a React Native frontend using Expo Router.  
Authentication and user management are implemented securely through JWT-based mechanisms, and password reset functionality via email is supported.  
The system is API-driven and ready for future integration with machine learning models for skin analysis.

## Technology Overview

**Backend Technologies:**
- FastAPI (Python)
- MongoDB Atlas (NoSQL Cloud Database)
- Motor (Async MongoDB client for Python)
- JWT (Access and Refresh token authentication)
- SMTP Protocol for email notifications
- Docker and Docker Compose for container orchestration

**Frontend Technologies:**
- React Native (Expo with TypeScript)
- Expo Router for structured navigation
- Axios for secure API communication
- Local Storage for session handling (migration to Secure Storage planned)

## Features

- Secure user registration with email validation
- User login with JWT-based authentication mechanism
- Password recovery and reset via email link
- Introductory onboarding flow for new users
- Home interface showing basic user information
- Application screens for improved user experience
- Seamless RESTful communication between frontend and backend services

## Current Status

- User authentication flows (Sign Up, Login, Forgot Password) are fully functional.
- JWT access and refresh token mechanisms are implemented and actively used.
- Password reset functionality is operational via email.
- Expo Router-based navigation flow is completed.
- MongoDB Atlas is fully integrated and accessed through Docker-managed backend services.

## Planned Features

- Skin analysis by uploading or capturing images
- Integration of a machine learning model for skin cancer prediction
- Real-time UV Index retrieval and exposure warnings
- User profile management and update features
- Notification system for sun protection alerts
- Secure Storage adoption for token management on mobile devices
- Admin panel for monitoring users and operations (optional)

## License

This project is distributed under the MIT License.  