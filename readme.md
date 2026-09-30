# web-apipatch

Static web host for **[apipatch.fix2ship.dev](https://apipatch.fix2ship.dev)**.

Hosts the product landing page and the Windows one-liner installation script:
```powershell
irm https://apipatch.fix2ship.dev/install.ps1 | iex
```

## Structure
- `index.html`: Modern, lightweight landing page.
- `install.ps1`: The PowerShell installation script for Windows users.
- `vercel.json`: Vercel configuration for serving `install.ps1` as plain text.

## Deployment to Vercel
1. Push this folder to a GitHub repository (e.g. `fix2ship/web-apipatch`).
2. Import project into Vercel.
3. Assign domain `apipatch.fix2ship.dev`.
