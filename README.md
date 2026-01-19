# ItinerMe

A modern, intelligent travel planning mobile application built with Flutter, Firebase, OpenAI, and Google Maps APIs.  
It helps users create, organize, and auto-generate personalized travel itineraries through AI-powered destination recommendations.

---

## ✨ Features

- 🔐 **Firebase Authentication** — Secure sign-in with persistent user sessions  
- ☁️ **Firestore Real-time Sync** — Trips update instantly across devices  
- 🤖 **AI-powered Itinerary Builder** — Automatically generate personalized daily travel plans  
- 🗺️ **Place Discovery** — Search and explore real-world destinations  
- ✏️ **Full Trip Editing** — Modify destinations, schedules, and trip dates freely  
- 🧭 **Live Directions & Travel Info** — View real-time distance and duration between destinations  
- ❤️ **Personal Trip Library** — Save, duplicate, and manage favorite trips  
- 🔍 **Smart Search & Sorting** — Find trips by name, date, or location  
- 📱 **Mobile-first UI** — Smooth and responsive experience across screen sizes  

---

## 📱 Screens

- **Dashboard** — Browse and search public trips  
- **My Collection** — Manage created and saved trips  
- **Trip Detail** — Day-by-day itinerary planning view  
- **Create Trip** — Generate full-trip travel plans with AI  
- **Account & Settings** — Manage user preferences  
- **Login & Sign-up** — Secure Firebase authentication flow  

---

## 🏗️ Tech Stack

- **Framework:** Flutter  
- **Language:** Dart  
- **State Management:** Provider / ChangeNotifier  
- **Authentication:** Firebase Authentication  
- **Database:** Cloud Firestore  
- **Storage:** Firebase Storage  
- **Maps & Location APIs:** Google Places API, Google Directions API  
- **AI Services:** OpenAI API  
- **Cloud Platform:** Firebase  
- **Tools:** Git, GitHub

---

## 🧠 AI Itinerary Flow

1. User selects trip destination, dates, and optional preferences  
2. OpenAI API generates personalized place suggestions for each day  
3. Google Places API resolves real-world location data  
4. Destinations are added to the itinerary  
5. Google Directions API computes travel distance and duration  
6. Firestore syncs updated trips in real time  
7. Users can freely modify dates, destinations, or regenerate daily plans  

---

## ⚙️ Getting Started

### Clone Repository
```bash
git clone https://github.com/quantr10/ItinerMe.git
cd ItinerMe
```

### Environment Setup
Copy the example environment file:

```bash
cp .env.example .env
```
Fill in required credentials in .env.

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
flutter run
```

### Supported platforms:
- Android
- iOS
- Web
- Windows

---
## 📸 Demo
(Add screenshots or GIFs here)

---
## 📄 License

[MIT](https://choosealicense.com/licenses/mit/)


