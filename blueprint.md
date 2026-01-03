# Zentry Admin Application Blueprint

## Overview

Zentry Admin is a sophisticated, internal-facing Flutter application designed for real-time monitoring and analysis of inbound sales calls. It leverages a Supabase backend for data persistence and provides a professional, minimalist user interface for administrators to track call metrics, review call details, and manage system baselines.

## Style, Design, and Features

### Version 1.0 (Current)

*   **Professional Minimalism:** The application adopts a clean, modern aesthetic with a focus on usability and clarity. The design language is inspired by top-tier products from Google and Microsoft, featuring:
    *   **Typography:** A refined font palette from `google_fonts` (`Montserrat`, `Lato`, `Roboto`) to create a strong visual hierarchy.
    *   **Color Scheme:** A sophisticated and cohesive color palette with a deep purple primary color, complemented by a range of neutral tones.
    *   **Layout & Spacing:** Deliberate use of spacing, padding, and alignment to create an uncluttered and breathable interface.
*   **Navigation Rail:** A permanent, modern `NavigationRail` on the left side provides intuitive navigation between the main sections of the app:
    *   Dashboard
    *   Call History
    *   Caller Overview (Placeholder)
    *   Admission Baselines (Placeholder)
*   **Dashboard:**
    *   A visually engaging grid of custom `StatCard` widgets, each displaying a key metric with a title, value, and icon.
*   **Call List & Detail:**
    *   A clean and readable list of calls with essential details.
    *   A detailed view for each call, including metadata, transcript, and other relevant information.
*   **Secure Credential Management:** The application uses the `flutter_dotenv` package to securely load Supabase credentials from a `.env` file, ensuring no sensitive information is hardcoded in the application.

## Current Plan

I am currently in the process of a major UI overhaul to elevate the application to a more professional and creative standard. The next steps are to:

1.  **Redesign the Call List Screen:** I will redesign the call list to be more visually appealing and informative, using custom widgets to display each call's information.
2.  **Enhance the Call Detail Screen:** I will enhance the call detail screen to present the information in a more organized and aesthetically pleasing way.
3.  **Implement the Caller Overview and Admission Baseline Screens:** I will replace the placeholder screens with fully functional screens that display the relevant data.
4.  **Add Animations and Micro-interactions:** I will introduce subtle animations and micro-interactions to enhance the user experience and create a more polished feel.
