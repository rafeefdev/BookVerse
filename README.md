# BookVerse 📚

A beautifully crafted mobile application for book enthusiasts, built with Flutter. BookVerse allows users to explore millions of books through the Google Books API, providing an intuitive and engaging reading discovery experience.

## ✨ Features

### Current Features
- **📖 Book Discovery**: Browse and explore books from the Google Books API
- **🔍 Intelligent Search**: Search books by title, author, or ISBN with real-time results
- **📑 Detailed Book Information**: View comprehensive book details including:
  - Title, subtitle, and description
  - Author(s) and publisher information
  - Publication date and page count
  - Book categories and thumbnail images
- **⭐ Bookmark System**: Save and organize your favorite books
- **🌓 Theme Support**: Light and dark mode toggle for comfortable reading
- **👀 Flexible View Modes**: Switch between grid and list view for saved books
- **🎯 Onboarding Experience**: Smooth introduction flow for new users

### Upcoming Features
- **🤖 AI Chatbot**: Get personalized book recommendations
- **📊 Reading Analytics**: Track your reading habits and progress
- **🔖 Advanced Bookmarking**: Create custom reading lists and categories
- **🔍 Enhanced Search Filters**: Filter by genre, rating, publication year, and more
- **📱 Improved UI/UX**: Modern, intuitive interface design
- **🌐 Social Features**: Share recommendations and reading progress

## 📱 Screenshots

*Screenshots coming soon - Stay tuned for visual previews of the app interface!*

## 🏗️ Architecture

BookVerse follows clean architecture principles with:

- **State Management**: Riverpod for reactive state management
- **Navigation**: Flutter's built-in navigation with custom routing
- **API Integration**: HTTP client for Google Books API
- **Local Storage**: Shared preferences for user settings and bookmarks
- **Theme Management**: Dynamic theming with system theme detection

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rafeefdev/BookVerse.git
   ```

2. **Navigate to project directory**
   ```bash
   cd BookVerse
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Set up environment variables**
   ```bash
   # Create a .env file in the root directory
   # Add your Google Books API key (if required)
   GOOGLE_BOOKS_API_KEY=your_api_key_here
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Core Dependencies
- **flutter_riverpod**: State management and dependency injection
- **http**: HTTP client for API requests
- **flutter_dotenv**: Environment configuration management

### UI & UX
- **flutter_chat_ui** & **flutter_chat_core**: Chat interface components
- **uuid**: Unique identifier generation

### Development Tools
- **riverpod_generator** (dev): Code generation for Riverpod
- **build_runner** (dev): Build system for code generation

## 🎨 Design Philosophy

BookVerse is designed with user experience at its core:

- **Minimalist Interface**: Clean, distraction-free design focusing on content
- **Intuitive Navigation**: Easy-to-understand user flows and interactions
- **Accessibility First**: Support for different themes and readable typography
- **Performance Optimized**: Efficient API calls with caching and pagination
- **Cross-Platform**: Consistent experience across different devices

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/          # Application constants
│   ├── models/             # Data models for the application
│   ├── providers/          # Riverpod providers for state management
│   ├── repositories/       # Data layer handling data sources
│   ├── services/           # Business logic and services
│   └── shared/             # Shared widgets and utilities
├── features/               # Feature-based modules
│   ├── auth/               # Authentication feature
│   ├── bookmarks/          # Bookmarks feature
│   ├── chatbot/            # AI chatbot feature
│   ├── home/               # Home screen feature
│   ├── onboarding/         # Onboarding screens
│   ├── search/             # Search feature
│   └── settings/           # Settings feature
└── main.dart               # Main application entry point
```

## 🤝 Contributing

We welcome contributions to BookVerse! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow Flutter/Dart best practices and conventions
- Maintain clean, readable code with proper documentation
- Ensure responsive design across different screen sizes
- Write meaningful commit messages
- Test your changes thoroughly before submitting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google Books API** for providing comprehensive book data
- **Flutter Team** for the amazing cross-platform framework
- **Riverpod** for excellent state management capabilities
- **Open Source Community** for continuous inspiration and support

## 📞 Contact

**Developer**: [Rafeef](https://github.com/rafeefdev)

**Project Link**: [https://github.com/rafeefdev/BookVerse](https://github.com/rafeefdev/BookVerse)

---

*Built with ❤️ using Flutter | Empowering readers to discover their next favorite book*
