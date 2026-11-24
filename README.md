# 🛒 CogniCart — AI-Powered Smart Price Comparison & Deal Intelligence Platform

![CogniCart Logo](public/assets/logo.png)

> **Compare Instantly. Save Massively.**  
> CogniCart is a full-stack, AI-powered e-commerce price intelligence platform and native mobile application that aggregates real-time product data across **Amazon, Flipkart, Google Shopping, Reliance Digital, and Croma**. It empowers shoppers with real-time price tracking, 30-day historical trend graphs, AI purchase advice, social proof metrics, automated price drop alerts, and a cross-platform Flutter mobile app.

---

## 🔗 Quick Links & Live Demos

- **🌐 Live Production Web App:** [https://cognicart-three.vercel.app](https://cognicart-three.vercel.app)
- **📱 Download Android APK:** [https://cognicart-three.vercel.app/CogniCart.apk](https://cognicart-three.vercel.app/CogniCart.apk)
- **🐙 GitHub Repository:** [https://github.com/Akhil-jatoth/CogniCart.git](https://github.com/Akhil-jatoth/CogniCart.git)
- **💻 Local Web Server:** [http://localhost:3000](http://localhost:3000) (when running `node script.js`)

---

## 📱 Native Flutter Mobile Application (`mobile/`)

CogniCart includes a native mobile application built using **Flutter & Dart**, replicating the website's dark glassmorphic interface, interactive components, and real-time backend synchronization.

### Mobile Features:
1. **🎨 4 Dynamic Background Themes with Reactive Color Matching:**
   - Automatically randomizes background theme on app launch (`Math.random() * 4`), matching the website behavior.
   - **Interactive Switcher:** Tap the palette icon (🎨) or the brand logo in the top navbar to cycle through themes anytime.
   - **Dynamic Global Color Palette:** When switching themes, all buttons, active nav icons, card borders, badge gradients, floating AI button, and dialogs dynamically transform:
     - **Solar Flare:** `bg1.png` — Vibrant Gold (`#FACC15`) & Coral Red (`#F87171`)
     - **Cyber Amber:** `bg2.png` — Cyber Amber (`#F59E0B`) & Bright Gold (`#FBBF24`)
     - **Neon Matrix:** `bg3.png` — Mint Emerald (`#10B981`) & Neon Purple (`#8B5CF6`)
     - **Deep Oceanic:** `bg4.png` — Electric Blue (`#3B82F6`) & Sky Cyan (`#60A5FA`)
2. **🛍️ Custom App Launcher Icon:**
   - High-resolution launcher icon generated directly from `public/assets/logo.png` across all density buckets (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`).
3. **⚡ Instant Optimistic UI Item Deletion:**
   - Tap delete on any item in your **Cart**, **Watchlist**, or **Price Radar**, and it vanishes immediately with zero UI lag, followed by server persistence.
4. **🔍 Real-Time Multi-Store Search & AI Top Pick:**
   - Parallel searches across Amazon, Flipkart, and other stores with AI recommendation badges highlighting the best deals.
5. **🤖 Floating CogniBot Assistant:**
   - Direct access to the AI shopping advisor right from any screen in the mobile app.

---

## 🌟 Key Highlights & Advanced Features

### 1. 🤖 CogniBot AI Shopping Assistant (Groq LLM Powered)
- **High-Speed AI Intelligence:** Integrated with **Groq Cloud API** running ultra-fast open-source LLMs (`openai/gpt-oss-120b`, `openai/gpt-oss-20b`, `qwen/qwen3.8-27b`).
- **Context-Aware Assistance:** Analyzes whether a product is worth buying at its current price, compares features, and explains pros and cons in simple, concise language without clutter.
- **Fail-Safe Fallback Pipeline:** Automatically queries active models and provides resilient multi-model failover.

### 2. 📦 Amazon-Style 3-Column Interactive Product View
- **Gallery & Rollover Zoom:** Product images with interactive zoom effects and one-click direct store redirect.
- **Specifications & Features:** Dynamically generates technical specifications and key feature bullets tailored to the product category (smartwatches, smartphones, laptops, audio gear, etc.).
- **Smart Financials:** Automatic MRP calculation, discount percentages, EMI monthly payment estimates, and applicable bank/cashback offers.
- **Sticky Buy Box:** Real-time stock status, verified seller badges, quantity selection, and instant 1-click checkout.

### 3. 📈 Interactive 30-Day Price History & Trend Graph
- **Custom SVG Area & Line Chart:** Visualizes price movements over the last 30 days (`30d ago`, `21d ago`, `14d ago`, `7d ago`, `Today`).
- **Price Drop Analytics:** Highlights peak price, 30-day average, lowest recorded price, and net savings (`📉 -₹XXX (-XX%) from peak`).
- **CogniCart Deal Score:** Dynamic deal score (e.g. `9.8/10 — Best time to buy`) advising users when to buy or wait.

### 4. 🔥 Social Proof & Live Demand Metrics
- **"How Many People Bought" Badge:** Amazon-style monthly purchase highlights (e.g. `🔥 5K+ bought in past month`).
- **Live Shopper Demand Card:** Real-time shopper metrics showing active daily viewers, items currently in carts, and orders placed in the last 24 hours.
- **Rating Sentiment Breakdown:** 5-star to 1-star visual percentage bars and verified buyer satisfaction percentages.

### 5. 🗂️ Unified Glassmorphism User Portal
- **🛒 Shopping Cart:** Grouped items with quantity management, store badges, price breakdowns, and direct checkout.
- **📦 My Orders:** Detailed order history with order dates, totals, item breakdowns, and modal views.
- **🕘 Search History:** Instant history log with one-click search replay.
- **📊 My Watchlist:** Live price tracking for saved products, lowest/highest recorded prices, and price-drop notifications.
- **🔔 Price Drop Alerts:** Custom target price thresholds with real-time status (`🎯 Target Reached!` vs `⏳ Need ₹... further drop`).

---

## 🛠️ Tech Stack & Technologies Used

### Mobile App
- **Flutter & Dart SDK:** High-performance cross-platform application.
- **Google Fonts:** Syne & DM Sans typography.
- **HTTP Client & Shared Preferences:** Network synchronization and persistent local storage.
- **Fl Chart:** Interactive price trend curves.

### Frontend Web
- **HTML5 & Vanilla JavaScript (ES6+):** Clean, lightweight Single-Page Application (SPA) architecture.
- **CSS3 Glassmorphism UI:** Modern dark aesthetic utilizing `backdrop-filter: blur()`, CSS custom properties, linear/radial gradients, and responsive CSS Grid/Flexbox.
- **SVG Data Visualization:** Vector-rendered area and line charts for historical price curves.

### Backend & Cloud
- **Node.js & Express.js:** RESTful API server handling search aggregation, cart operations, user sessions, and price alerts.
- **Groq SDK / OpenAI-Compatible API:** Ultra-low latency LLM inference for CogniBot.
- **Vercel Serverless Functions:** Serverless cloud hosting with `/tmp` persistent storage fallback.
- **MongoDB Atlas:** Cloud database integration with auto-sync and resilient failover.
- **Bcrypt.js:** Secure password hashing.
- **Brevo / Nodemailer:** Email delivery for OTP verification and automated price drop alerts.

---

## 🚀 Getting Started

### 1. Web Application Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Akhil-jatoth/CogniCart.git
   cd CogniCart
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the root directory:
   ```env
   PORT=3000
   GROQ_API_KEY=your_groq_api_key_here
   MONGODB_URI=your_mongodb_atlas_connection_string
   BREVO_API_KEY=your_brevo_api_key
   SCRAPER_API_KEY=your_scraper_api_key
   ```

4. **Start the application:**
   ```bash
   node script.js
   ```

5. **Open in your browser:**
   ```
   http://localhost:3000/
   ```

---

### 2. Flutter Mobile Application Setup

1. **Navigate to the mobile directory:**
   ```bash
   cd mobile
   ```

2. **Fetch Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on an Android device or emulator:**
   ```bash
   flutter run
   ```

4. **Build Production Release APK:**
   ```bash
   flutter build apk --release
   ```
   The compiled APK will be output to:
   ```
   mobile/build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 📁 Project Structure

```
CogniCart/
├── api/
│   ├── index.js              # Express REST API, search scraping & Groq AI routes
│   └── vercel.js             # Vercel serverless entry point
├── mobile/                   # Flutter Native Mobile Application
│   ├── android/              # Android native wrapper & launcher mipmaps
│   ├── assets/               # Mobile logo & background artwork
│   ├── lib/
│   │   ├── main.dart         # Mobile application entry & theme provider
│   │   ├── models/           # Data models (Product, Watchlist, Alert, Order)
│   │   ├── screens/          # Search, Watchlist, Alerts, Cart, Profile screens
│   │   ├── services/         # API & Storage services
│   │   ├── theme/            # Dynamic 4-theme color engine
│   │   └── widgets/          # Navigation, Modals, Cards, AI Assistant
│   └── pubspec.yaml          # Flutter dependencies & assets
├── public/
│   ├── assets/               # Logos, icons, background artwork
│   ├── index.html            # Main SPA frontend (Search, Product View, Cart, Watchlist, Alerts)
│   ├── style.css             # Glassmorphism design system & responsive styles
│   ├── CogniCart.apk         # Direct download copy of release APK
│   ├── profile.html          # User profile & stats dashboard
│   ├── watchlist.html        # Watchlist redirect & fallback
│   └── alerts.html           # Price alerts redirect & fallback
├── CogniCart.apk             # Root release APK (installable on Android)
├── script.js                 # Node server entry point
├── users.json                # User storage & cart/orders persistence
├── package.json              # Project dependencies & scripts
└── README.md                 # Project documentation
```

---

## 👥 Contributors & Author
- **Akhil Jatoth** — [GitHub Profile](https://github.com/Akhil-jatoth)
