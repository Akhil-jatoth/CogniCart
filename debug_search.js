require("dotenv").config();
const axios = require("axios");

function env(key) { return (process.env[key] || "").trim(); }

async function scrapeAmazonDebug(query) {
  const apiKey = env("RAINFOREST_API_KEY");
  console.log("API Key present:", !!apiKey, "| First 8 chars:", apiKey.slice(0, 8));

  try {
    console.log("Calling Rainforest API for:", query);
    const { data } = await axios.get("https://api.rainforestapi.com/request", {
      params: { api_key: apiKey, type: "search", amazon_domain: "amazon.in", search_term: query, page: 1 },
      timeout: 25000,
    });

    console.log("Response keys:", Object.keys(data || {}));
    const searchResults = Array.isArray(data?.search_results) ? data.search_results : [];
    console.log("search_results count:", searchResults.length);

    if (data?.request_info) console.log("request_info:", JSON.stringify(data.request_info));
    if (searchResults.length === 0 && data?.error) console.log("API Error:", data.error);

    const results = [];
    for (const product of searchResults.slice(0, 5)) {
      const title = product?.title ?? "";
      const priceVal = product?.price?.value;
      const priceRaw = priceVal != null ? priceVal : (product?.price ? String(product.price) : "");
      const price = String(priceRaw).replace(/,/g, "").replace(/[^\d.]/g, "");
      const rating = product?.rating != null ? String(product.rating) : null;
      const ratingCount = product?.ratings_total != null ? String(product.ratings_total).replace(/,/g, "") : null;
      const image = product?.image ?? "";
      const link = product?.link ?? "";

      console.log(`\n  [${results.length + 1}] title="${title.substring(0,45)}" price="${price}" rating=${rating} reviews=${ratingCount} valid=${!!(title && price)}`);

      if (title && price) {
        results.push({ title: title.substring(0, 60) + (title.length > 60 ? "..." : ""), price, rating, ratingCount, image, link, store: "Amazon" });
      }
    }

    console.log("\n✅ Final mapped products:", results.length);
    if (results[0]) {
      console.log("Sample:", JSON.stringify(results[0], null, 2));
    }
  } catch (e) {
    console.error("❌ Error:", e.message);
    if (e.response) {
      console.error("HTTP Status:", e.response.status);
      console.error("Response body:", JSON.stringify(e.response.data));
    }
  }
}

scrapeAmazonDebug("laptop");
