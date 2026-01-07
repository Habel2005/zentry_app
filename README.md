# Zentry App 📱

A powerful Flutter-based mobile dashboard for the **Zentry AI** platform. This application provides real-time monitoring, analytics, and insights into AI-driven voice interactions, allowing administrators to track call performance, STT (Speech-to-Text) quality, and agent handoffs.

## 🚀 Features

* **Real-Time Dashboard**:
    * Monitor key metrics instantly: **Total Calls**, **Ongoing Interactions**, and **Dropped Calls**.
    * Visual indicators for system health and load.
* **AI vs. Human Analytics**:
    * Interactive charts displaying the ratio of calls handled purely by AI versus those requiring human intervention.
* **Quality Insights**:
    * **STT Quality Distribution**: visual breakdown of speech-to-text accuracy (Good, Low, Failed) to diagnose transcription issues.
    * **Latency Tracking**: Monitor processing speeds for various AI steps.
* **Call Management**:
    * **Call Logs**: Detailed history of interactions (inferred from `call_log_screen.dart`).
    * **Deep Dive**: Inspect specific call details, including AI processing steps and guardrail triggers (inferred from `call_detail_screen.dart` and `ai_processing_step.dart`).
* **Robust User Experience**:
    * **Authentication**: Secure login integrated with Supabase Auth.
    * **Dark & Light Mode**: Fully adaptive UI with custom themes.
    * **Connectivity Handling**: Built-in offline detection and user alerts.
    * **Rich Animations**: Engaging UI elements powered by Rive.

## 🛠 Tech Stack

* **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.9.0)
* **Backend / Auth**: [Supabase](https://supabase.com/)
* **State Management**: [Provider](https://pub.dev/packages/provider)
* **Visualization**: [FL Chart](https://pub.dev/packages/fl_chart) for analytics graphs.
* **Animations**: [Rive](https://rive.app/) for interactive assets.
* **Networking**: `http` & `connectivity_plus`

## 📂 Project Structure

lib/    
├── models/ # Data models (DashboardData, CallDetail, AiProcessingStep) 
├── assets/ # Rive animations, images, and fonts 
├── dashboard_screen.dart # Main analytics view with charts 
├── login_screen.dart # Authentication handler 
├── main.dart # Entry point and app configuration 
├── supabase_service.dart # Backend communication layer └── ...


## 🏁 Getting Started

### Prerequisites

* Flutter SDK installed (Version 3.9.0 or higher recommended).
* A Supabase project set up for Zentry.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/yourusername/zentry_app.git](https://github.com/yourusername/zentry_app.git)
    cd zentry_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Environment Configuration:**
    Create a `.env` file in the root directory (added to `.gitignore` for security) and add your Supabase credentials:
    ```env
    SUPABASE_URL=your_supabase_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    ```

4.  **Run the App:**
    ```bash
    flutter run
    ```

## 🧪 Testing

The project includes unit and widget tests. Run them using:

```bash
flutter test
```
## 📄 License
MIT