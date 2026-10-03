# web-apipatch

Static web host for **[apipatch.fix2ship.dev](https://apipatch.fix2ship.dev)**.

Hosts the product landing page and the Windows one-liner installation script:
```powershell
irm https://apipatch.fix2ship.dev/install.ps1 | iex
```

## Structure
- `index.html`: Modern, lightweight landing page.
- `install.ps1`: The PowerShell installation script for Windows users.
- `api/feedback.js`: Serverless API route receiving anonymous user telemetry and feedback (`POST /api/feedback`).
- `vercel.json`: Vercel configuration for serving `install.ps1` as plain text.

## Environment Variables (Optional for Database Ingestion)
When deployed to Vercel, you can connect your Supabase database without exposing credentials to users:
- `SUPABASE_URL`: Your Supabase Project URL (`https://<project-id>.supabase.co`).
- `SUPABASE_SERVICE_ROLE_KEY`: Supabase secret service role key (enables server-side ingestion).

## Deployment to Vercel
1. Push this folder to a GitHub repository (e.g. `fix2ship/web-apipatch`).
2. Import project into Vercel.
3. Assign domain `apipatch.fix2ship.dev`.
