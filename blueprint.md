# Zentry Insights Dashboard

This document outlines the development of the Zentry Insights dashboard, a Flutter application designed to provide insights into call center data.

## Overview

The Zentry Insights dashboard is a Flutter application that provides a comprehensive overview of call center data. The application is designed to be a single-page application that allows users to view key performance indicators (KPIs), a list of calls, and detailed information for each call. The application is built using Flutter and Supabase.

## Style and Design

The application follows a modern and clean design aesthetic. The color palette is based on a slate blue primary color, with a light gray background. The application uses a consistent design language, with a focus on readability and usability. The application is designed to be responsive and work well on both mobile and desktop devices.

## Features

### 1. Dashboard

The dashboard provides a high-level overview of the call center's performance. The dashboard displays the following KPIs:

*   Total Calls
*   Ongoing Calls
*   Dropped Calls
*   AI Handled Calls
*   STT Good
*   STT Low

### 2. Call List

The call list displays a list of all calls. Each call in the list displays the call ID, start time, duration, and language. The call list also indicates if a caller is a repeat caller and the status of the call.

### 3. Call Details

The call details screen provides detailed information for each call. The call details screen displays the call metadata, a transcript of the call, and a timeline of the AI processing steps.

### 4. Authentication

The application includes a login screen to authenticate users. The login screen is a simple form with fields for email and password. Once authenticated, the user is redirected to the home screen.

### 5. Navigation

The application uses a bottom navigation bar to navigate between the different screens. The navigation bar includes links to the dashboard, call list, caller overview, and admission baseline screens.

## Current Plan

1.  **Create `blueprint.md`:** Create a `blueprint.md` file to document the project.
2.  **Add Dependencies:** Add the `supabase_flutter` dependency to the `pubspec.yaml` file.
3.  **Supabase Setup:** Create a `supabase_service.dart` file to initialize the Supabase client and a `queries.dart` file to fetch data from the Supabase views.
4.  **Data Models:** Create Dart models for the `dashboard_overview`, `call_list_item`, and `call_detail` data.
5.  **Placeholder Screens:** Create placeholder screens for the `CallerOverviewScreen` and `AdmissionBaselineScreen`.
6.  **Dashboard:** Implement the `DashboardScreen` to display the KPIs.
7.  **Call List:** Implement the `CallListScreen` to display a list of calls.
8.  **Call Detail:** Implement the `CallDetailScreen` to display the detailed information for a selected call.
9.  **UI Components:** Create the `StatCard`, `Badge`, and `AppTheme` UI components.
10. **Authentication and Navigation:** Create the `login_screen.dart` and `home_screen.dart` files to handle authentication and navigation.
11. **Update `main.dart`:** Update the `main.dart` file to include the routes and the theme.
