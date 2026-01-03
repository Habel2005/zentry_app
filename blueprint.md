
# Admin Panel Blueprint

## Overview

This document outlines the design and features of a Flutter-based admin panel for monitoring and analyzing call data from a Supabase backend. The application is designed to be a "hardcore" enterprise-grade tool with a focus on data density, performance, and a professional user experience.

## Style, Design, and Features

### Architecture

*   **State Management:** `provider` for theme management.
*   **Routing:** `go_router` for declarative navigation and deep linking.
*   **Data Layer:** `supabase_flutter` for real-time data fetching from Supabase views.
*   **Styling:** Material 3 with a professional color scheme and `google_fonts` for typography.

### Data Models

The application uses the following data models, which correspond to the Supabase database views:

*   `AdminCallsOverview`: Aggregated call metrics for the dashboard.
*   `AdminCallList`: A list of all calls with summary data.
*   `CallDetail`: Detailed information for a single call, including the full transcript and AI processing timeline.
*   `SttQualityDistribution`: A nested model within `AdminCallsOverview` to represent the distribution of STT quality.
*   `AiProcessingStep`: A model for a single step in the AI processing pipeline.
*   `TranscriptItem`: A model for a single item in the call transcript.

### File and Folder Structure

```
lib/
├── models/
│   ├── admin_calls_overview.dart
│   ├── admin_call_list.dart
│   ├── call_detail.dart
│   ├── stt_quality_distribution.dart
│   ├── ai_processing_step.dart
│   └── transcript_item.dart
├── screens/
│   ├── login_screen.dart
│   ├── main_screen.dart
│   ├── dashboard_screen.dart
│   ├── call_log_screen.dart
│   └── call_detail_screen.dart
├── services/
│   └── supabase_service.dart
├── widgets/
│   └── stat_card.dart
├── main.dart
└── theme_provider.dart
```

### Screens

#### 1. Login Screen

*   **Route:** `/login`
*   **Functionality:**
    *   Allows users to sign in with email and password.
    *   Handles authentication against the Supabase `auth.users` table.
    *   Redirects to the main application upon successful login.

#### 2. Main Screen (Shell Route)

*   **Route:** `/`
*   **Functionality:**
    *   Acts as the main application shell, containing the `NavigationRail`.
    *   The `NavigationRail` provides access to the Dashboard, Call Log, and Profile screens.
    *   Includes a theme toggle for switching between light and dark modes.
    *   Contains the user's profile information and a logout button.

#### 3. Dashboard Screen

*   **Route:** `/` (nested within the `MainScreen` shell)
*   **Functionality:**
    *   Displays a real-time overview of key call metrics from the `admin_calls_overview` view.
    *   Uses responsive `KpiCard` widgets to display stats like total calls, ongoing calls, dropped calls, and the AI vs. human ratio.
    *   Includes a placeholder for a chart to visualize the STT quality distribution.

#### 4. Call Log Screen

*   **Route:** `/` (nested within the `MainScreen` shell, this is the default screen)
*   **Functionality:**
    *   Displays a paginated and sortable table of all calls from the `admin_call_list` view.
    *   Uses a `PaginatedDataTable` to provide a professional, data-dense view of the call history.
    *   Columns include Start Time, Duration, Status, Language, STT Quality, and a "Repeat Caller" badge.
    *   Allows users to navigate to the `CallDetailScreen` by clicking on a row.
    *   Includes a placeholder for filtering functionality.

#### 5. Call Detail Screen

*   **Route:** `/calls/:id` (nested within the `MainScreen` shell)
*   **Functionality:**
    *   Provides a comprehensive, three-section view of a single call from the `admin_call_detail` view.
    *   **Metadata:** A header section with key call information.
    *   **Transcript Viewer:** A chat-bubble-style display of the conversation, with visual indicators for low-confidence STT.
    *   **AI Processing Timeline:** A chronological list of AI pipeline steps, including status and latency.

## Current Plan

The current plan is to continue building out the features and functionality of the application, with a focus on the following:

*   **Implementing Filtering:** Add filtering capabilities to the `CallLogScreen`.
*   **STT Quality Chart:** Implement the STT quality distribution chart on the `DashboardScreen`.
*   **Real-time Updates:** Ensure that the dashboard and call log update in real-time as new data becomes available in Supabase.
*   **Error Handling:** Enhance error handling and provide more informative error messages to the user.
*   **UI Polish:** Continue to refine the UI and UX of the application to meet the "hardcore" enterprise standard.
