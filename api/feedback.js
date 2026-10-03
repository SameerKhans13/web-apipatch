// Vercel Serverless Function: api/feedback.js
// Handles POST /api/feedback requests from apipatch CLI

module.exports = async (req, res) => {
  // CORS configuration
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, apikey, Authorization");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method Not Allowed" });
  }

  try {
    let body = req.body;
    if (typeof body === "string") {
      try {
        body = JSON.parse(body);
      } catch {
        // use raw body
      }
    }
    body = body || {};

    if (!body.category || typeof body.category !== "string") {
      return res.status(400).json({ error: "Missing or invalid category" });
    }

    if (!body.message || typeof body.message !== "string") {
      return res.status(400).json({ error: "Missing or invalid message" });
    }

    const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

    // If Supabase credentials are configured in Vercel environment variables, insert directly
    if (supabaseUrl && supabaseServiceKey) {
      const response = await fetch(`${supabaseUrl.replace(/\/+$/, "")}/rest/v1/feedback`, {
        method: "POST",
        headers: {
          "apikey": supabaseServiceKey,
          "Authorization": `Bearer ${supabaseServiceKey}`,
          "Content-Type": "application/json",
          "Prefer": "return=representation",
        },
        body: JSON.stringify({
          apipatch_version: body.apipatch_version || null,
          category: body.category,
          ecosystem: body.ecosystem || null,
          error_code: body.error_code || null,
          message: body.message,
          os_platform: body.os_platform || null,
          rating: body.rating != null ? Number(body.rating) : null,
          run_phase: body.run_phase || null,
          status: body.status || null,
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error("Supabase insert error:", response.status, errorText);
        return res.status(502).json({ error: "Failed to persist feedback upstream", detail: errorText, status: response.status });
      }

      const data = await response.json();
      const feedbackId = Array.isArray(data) && data[0]?.id ? data[0].id : undefined;
      return res.status(201).json([{ id: feedbackId || "ack" }]);
    }

    // Fallback: If DB isn't configured yet, acknowledge receipt and log
    console.log("Feedback received without Supabase credentials configured:", {
      category: body.category,
      rating: body.rating,
      messageLength: body.message.length,
      platform: body.os_platform,
      version: body.apipatch_version,
    });

    return res.status(201).json([{ id: `ack-${Date.now()}` }]);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error("Error processing feedback:", message);
    return res.status(500).json({ error: "Internal server error", message });
  }
};
