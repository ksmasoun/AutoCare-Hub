# AutoCare Hub 🚗🛠️

AutoCare Hub is an iOS app that helps drivers manage their vehicles and make smarter service decisions by combining vehicle details, nearby provider discovery, and safety context.

## Features

- Create an account and sign in (including Google Sign-In) 
- Register one or more vehicles and store key details 
- View saved vehicles and open a vehicle profile for more insights 
- Appointment scheduling with nearby providers
- Service history tracking (appointments, notes, receipts)
- REST API integration for real-time availability and pricing
- Notifications and reminders for service milestones
- Find nearby vehicle service providers on a map
- Get basic weather-based alerts to help plan safer trips 

## Tech stack 🧰

- MapKit + CoreLocation (maps, searching, nearby places) 📍
- WeatherKit (weather-driven alerts) 🌧️
- Google Sign-In 🔑

## Data & persistence 💾

The app stores user and vehicle data locally so it remains available between launches.

## Getting started 🚀

1. Open the project in Xcode.
2. Set your **Signing & Capabilities** (your Apple Developer team).
3. Resolve dependencies (if the project uses CocoaPods/SPM, run the usual install step for your setup).
4. Build and run on the iOS Simulator or a device.

## Configuration ⚙️

### Google Sign-In 🔐

If you fork this repo, you’ll need to configure your own Google OAuth credentials:

- Create an OAuth client in Google Cloud Console
- Add the iOS bundle identifier
- Update the app’s Google Sign-In configuration values accordingly

### Location & privacy 📍

The app uses location to find nearby providers. Ensure the required location permission strings are present and accurate for App Store distribution.

## Contributing 🤝

Pull requests are welcome. For major changes, please open an issue first to discuss what you’d like to change.

## License 📄

This project is licensed under the **MIT License**. See `LICENSE` for details.
