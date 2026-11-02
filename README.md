# 🛒 CogniCart — AI-Powered Smart Price Comparison & Deal Intelligence Platform

![CogniCart Banner](public/assets/logo.png)

> **Compare Instantly. Save Massively.**  
> CogniCart is a full-stack, AI-powered e-commerce price intelligence platform that aggregates real-time product data across **Amazon, Flipkart, Google Shopping, Reliance Digital, and Croma**. It empowers shoppers with real-time price tracking, 30-day historical trend graphs, AI purchase advice, social proof metrics, and automated price drop alerts.

---

## 🌟 Key Highlights & Advanced Features

### 1. 🤖 CogniBot AI Shopping Assistant (Groq LLM Powered)
- **High-Speed AI Intelligence:** Integrated with **Groq Cloud API** running state-of-the-art open-source LLMs (`openai/gpt-oss-120b`, `openai/gpt-oss-20b`, `qwen/qwen3.8-27b`).
- **Context-Aware Assistance:** Answers user queries about whether a product is worth buying at its current price, compares features, and explains pros and cons in simple, concise language without clutter.
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

### 5. 🌟 Cross-Store Recommendations ("Customers Also Viewed")
- Dynamically populates matching alternative products and deals from other stores (Amazon vs Flipkart vs Reliance Digital).
- 1-click in-page navigation to view any recommended product's full page without page reloads.

### 6. 🗂️ Unified Glassmorphism User Portal (Single-Page App)
- **🛒 Shopping Cart:** Grouped items with quantity management, store badges, price breakdowns, and direct checkout.
- **📦 My Orders:** Detailed order history with order dates, totals, item breakdowns, and modal views.
- **🕘 Search History:** Instant history log with one-click search replay.
- **📊 My Watchlist:** Live price tracking for saved products, lowest/highest recorded prices, and price-drop notifications.
- **🔔 Price Drop Alerts:** Custom target price thresholds with real-time status (`🎯 Target Reached!` vs `⏳ Need ₹... further drop`).
- **🛡️ Fixed Layout & Zero Layout Shift:** Fixed top navigation bar and locked background viewport layer preventing any page jumping or background scrolling stutter.

---

## 🛠️ Tech Stack & Technologies Used

### Frontend
- **HTML5 & Vanilla JavaScript (ES6+):** Clean, lightweight Single-Page Application (SPA) architecture with zero framework bloat.
- **CSS3 Glassmorphism UI:** Modern dark aesthetic utilizing `backdrop-filter: blur()`, CSS custom variables, linear/radial gradients, and responsive CSS Grid/Flexbox.
- **SVG Data Visualization:** Vector-rendered area and line charts for crisp historical price curves on any screen resolution.
- **Zero-Layout-Shift:** `scrollbar-gutter: stable` and `position: fixed` header and background layers for rock-solid stability.

### Backend & Server
- **Node.js & Express.js:** RESTful API server handling search aggregation, cart operations, user sessions, and price alerts.
- **Groq SDK / OpenAI-Compatible API:** Ultra-low latency LLM inference for CogniBot.
- **Bcrypt.js:** Secure password hashing.
- **Nodemailer:** Email delivery for OTP verification and automated price drop alerts.
- **Axios & Cheerio:** Multi-store data scraping and API aggregation.
- **Persistence:** Local JSON data store (`users.json`) with in-memory caching for rapid responses.

---

## 🚀 Getting Started

### Prerequisites
- [Node.js](https://nodejs.org/) (v16 or higher recommended)
- [npm](https://www.npmjs.com/)

### Installation

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
   EMAIL_USER=your_email@gmail.com
   EMAIL_PASS=your_email_app_password
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

## 📁 Project Structure

```
CogniCart/
├── api/
│   └── index.js              # Express REST API, search scraping & Groq AI routes
├── public/
│   ├── assets/               # Logos, icons, background artwork
│   ├── index.html            # Main SPA frontend (Search, Product Page, Cart, Watchlist, Alerts)
│   ├── style.css             # Glassmorphism design system & responsive styles
│   ├── profile.html          # User profile & stats dashboard
│   ├── watchlist.html        # Watchlist redirect & fallback
│   └── alerts.html           # Price alerts redirect & fallback
├── script.js                 # Node server entry point
├── users.json                # User storage & cart/orders persistence
├── package.json              # Project dependencies & scripts
└── README.md                 # Project documentation
```

---

## 👥 Contributors & Author
- **Akhil Jatoth** — [GitHub Profile](https://github.com/Akhil-jatoth)
