require("dotenv").config();

const express = require("express");
const cors = require("cors");
const path = require("path");
const axios = require("axios");

const app = express();

// Allow Live Server (5500/5501), local Node (3000), and Vercel deployments
const allowedOrigins = [
  "http://localhost:3000",
  "http://127.0.0.1:3000",
  "http://localhost:5500",
  "http://127.0.0.1:5500",
  "http://localhost:5501",
  "http://127.0.0.1:5501",
];
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (curl, Postman, Vercel server-side)
      if (!origin) return callback(null, true);
      if (allowedOrigins.includes(origin) || origin.endsWith(".vercel.app")) {
        callback(null, true);
      } else {
        callback(new Error("CORS: origin not allowed – " + origin));
      }
    },
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);
app.use(express.json());

// ─── In-memory search cache (replaces MongoDB CachedSearch) ──────────────────
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours
const searchCache = new Map(); // key: normalizedQuery → { results, expiresAt }

console.log("ℹ️  Running in no-DB mode: search results cached in memory.");

// Serve static frontend assets
app.use(express.static(path.join(__dirname, "public")));
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

// ─── Rainforest API Amazon search ────────────────────────────────────────────
app.get("/search/amazon", async (req, res) => {
  const rawQuery = req.query.q ?? req.query.query ?? req.query.search_term;
  const searchTerm = rawQuery ? String(rawQuery).trim() : "";

  if (!searchTerm) {
    return res.status(400).json({ error: "Missing search query." });
  }

  const normalizedQuery = searchTerm.toLowerCase();

  // Serve from in-memory cache if fresh
  const cached = searchCache.get(normalizedQuery);
  if (cached && Date.now() < cached.expiresAt) {
    return res.json(cached.results);
  }

  const rainforestApiKey = process.env.RAINFOREST_API_KEY;
  if (!rainforestApiKey) {
    return res.status(500).json({ error: "RAINFOREST_API_KEY is not configured." });
  }

  try {
    const rainforestResponse = await axios.get(
      "https://api.rainforestapi.com/request",
      {
        params: {
          api_key: rainforestApiKey,
          type: "search",
          amazon_domain: "amazon.in",
          search_term: searchTerm,
        },
        timeout: 20000,
      },
    );

    const searchResults = Array.isArray(rainforestResponse.data?.search_results)
      ? rainforestResponse.data.search_results
      : [];

    const mappedProducts = searchResults.map((product) => {
      const priceRaw = product?.price?.value ?? (product?.price ? String(product.price) : "");
      const price = String(priceRaw).replace(/,/g, "").replace(/[^\d.]/g, "");
      const rating =
        product?.rating != null && !Number.isNaN(Number(product.rating))
          ? Number(product.rating)
          : 0;
      const ratingCount = Number(
        String(product?.ratings_total ?? "0").replace(/,/g, ""),
      );

      return {
        title: product?.title ?? "",
        price,
        image: product?.image ?? "",
        rating,
        ratingCount: Number.isFinite(ratingCount) ? ratingCount : 0,
        link: product?.link ?? "",
        store: "amazon",
      };
    });

    // Store in in-memory cache
    searchCache.set(normalizedQuery, {
      results: mappedProducts,
      expiresAt: Date.now() + CACHE_TTL_MS,
    });
    // Evict oldest if cache grows large
    if (searchCache.size > 200) {
      searchCache.delete(searchCache.keys().next().value);
    }

    return res.json(mappedProducts);
  } catch (error) {
    console.error("Amazon search failed:", error?.message ?? error);
    if (error.response) {
      return res
        .status(error.response.status || 502)
        .json({ error: error.response.data || "Rainforest API error." });
    }
    return res
      .status(500)
      .json({ error: "Unable to fetch Amazon search results." });
  }
});

// Mount the API router
app.use("/api", require("./api"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🔥 CogniCart backend running on port ${PORT}`);
  console.log(`👉 Open http://localhost:${PORT} in your browser!`);
});
