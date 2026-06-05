# BookVerse 📚

A high-performance, feature-rich Flutter application designed for book discovery and reading habit analytics. Built with a modern reactive architecture, it integrates local persistence with cloud synchronization and provides deep insights into user reading patterns.

## 🛠 Technical Stack

- **Framework:** Flutter (Stable)
- **State Management:** [Riverpod](https://riverpod.dev/) (Reactive caching, dependency injection, and data fetching)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router) (Declarative, URL-aware routing with shell branches)
- **Persistence (Local):** [Sqflite](https://pub.dev/packages/sqflite) (Optimized relational storage for reading sessions and tracking)
- **Backend & Auth:** [Supabase](https://supabase.com/) (PostgreSQL-based backend for real-time synchronization and secure authentication)
- **Code Push:** [Shorebird](https://shorebird.dev/) (Enterprise-grade OTA updates)
- **API Integration:** Google Books API for comprehensive metadata retrieval

## 🚀 Core Features

- **Reading Insights Engine:**
    - Dynamic streak tracking (Active, At Risk, Broken status logic).
    - 90-day activity heatmap with intensity levels based on daily reading duration.
    - Automated achievement system with progress tracking and unlock triggers.
- **Reading Tracker:**
    - Granular session logging (start/end pages, duration, timestamp).
    - Real-time progress synchronization with Supabase.
- **Library Management:**
    - Local-first architecture with offline support.
    - Multi-mode display (Grid/List) and complex filtering.
- **Discovery & Search:**
    - Real-time search indexing via Google Books API.
    - Category-based exploration and personalized recommendations.

## 🏗 Architecture & Project Structure

The project follows a **Feature-First Modular Architecture**, promoting high cohesion and low coupling.

```text
lib/
├── core/                   # Cross-cutting concerns
│   ├── auth/               # Supabase-based authentication logic
│   ├── router/             # GoRouter configuration & ShellScaffold
│   ├── services/           # DB (Sqflite), Supabase, and Backup services
│   └── shared/             # Theme tokens, extensions, and common components
└── features/               # Functional modules
    ├── insights/           # Reading analytics, streaks, and heatmap logic
    ├── reading_tracker/    # Session logging and progress calculation
    ├── dashboard/          # Aggregated user stats and summary
    ├── library/            # Local collection management
    ├── search/             # API discovery layer
    ├── onboarding/         # User introduction and setup flow
    ├── home/               # Featured content and landing views
    ├── bookmarks/          # Saved and organized favorites
    └── settings/           # User preferences and app configuration
```

## 💻 Development Setup

### Prerequisites

- Flutter SDK (latest stable)
- Supabase account (for backend features)
- Google Books API Key

### Configuration

1. **Environment Variables:**
   Create a `.env` file in the root directory. This file is required as it is bundled in the application assets. Add the following keys:
   ```env
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   GOOGLE_BOOKS_API_KEY=your_google_books_api_key
   GOOGLE_WEB_CLIENT_ID=your_google_web_client_id
   ```

2. **Initialize Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Code Generation (if applicable):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run Project:**
   ```bash
   flutter run
   ```

## 🔧 Implementation Details

- **Heatmap Logic:** The heatmap in `lib/features/insights/view/insights_page.dart` uses a 7xN grid layout representing weeks. Intensity is calculated via duration mapping in the `InsightsViewModel`.
- **Relational Integrity:** Local Sqflite tables maintain foreign key relationships between `books` and `reading_sessions` to ensure data consistency during offline-first operations.
- **Sync Strategy:** The `BackupService` manages the reconciliation between local SQLite snapshots and remote Supabase PostgreSQL records.

---
*Maintained by developers for developers.*
