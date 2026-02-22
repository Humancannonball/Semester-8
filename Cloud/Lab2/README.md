# OpenTofu PaaS Lab — Azure Web App

> **Laboratory Work 02** — Integrated Services Networks & Cloud Technologies (VilniusTech)

Deploy a PaaS resource on Azure using Infrastructure as Code ([OpenTofu](https://opentofu.org/)). This project uses an **Azure App Service (Linux Web App)** on the Free tier in `swedencentral`, which serves as a functionally identical alternative to Azure Static Web Apps (which are restricted by the subscription's region policy).

## Architecture & Integration

```
                 GitHub Repository (index.html)
                              │
                     GitHub Actions CI/CD
                    (Triggered on Git Push)
                              │
                              ▼
┌──────────────────── Resource Group: PaaS_group ─────────────────────┐
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │                     App Service Plan                          │   │
│  │                     Tier: LinuxFree (F1)                      │   │
│  └──────────────────────────────┬────────────────────────────────┘   │
│                                 │                                    │
│  ┌──────────────────────────────▼────────────────────────────────┐   │
│  │                       Linux Web App                           │   │
│  │                 (Hosts the HTML content)                      │   │
│  └──────────────────────────────▲────────────────────────────────┘   │
│                                 │                                    │
│  Tag: ENV = PaaS                │                                    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  │
                       Custom Domain Mapping
                 (name_paas.dclab.lt → Azure Web App)
                                  │
                                  ▼
                   Cloudflare DNS (CNAME Record)
                                  │
                                  ▼
                            Internet / Users
```

## Setup & Deployment

1. **Authenticate:** `az login`
2. **Initialize:** `tofu init`
3. **Deploy:** `tofu apply`
4. **Note the Outputs:** You'll get the Azure-assigned `.azurewebsites.net` URL.

## Manual Steps (Lab Requirements)

Once the infrastructure is deployed, complete the CI/CD and DNS setup:

### 1. GitHub Integration (Tasks 1.1–1.4 & 2.5–2.6)
1. Create a GitHub repository and add your `index.html`.
2. Go to the Azure Portal → Find the created Web App (`mark-paas-...`).
3. On the left menu, click **Deployment Center**.
4. Select **GitHub** as the source, authorize, and select your repository/branch.
5. Save. This automatically creates a GitHub Actions workflow in your repo (Tasks 2.14–2.16).

### 2. Custom Domain & Cloudflare (Tasks 2.10–2.12)
1. Log into Cloudflare and navigate to the `dclab.lt` zone.
2. Add a **CNAME** record:
   - Name: `name_paas` (replace with your identifier)
   - Target: The `web_url` output from OpenTofu (e.g., `mark-paas-abcd.azurewebsites.net`)
   - Proxy status: **DNS Only** (grey cloud)
3. Add a **TXT** record (for Azure verification):
   - Name: `asuid.name_paas`
   - Target: The `custom_domain_verification_id` output from OpenTofu.
4. Go to the Azure Portal → Web App → **Custom Domains**.
5. Click **Add custom domain**, enter `name_paas.dclab.lt`, and validate.

## Cleanup

When finished with the lab, destroy all resources to avoid any potential charges:
```bash
tofu destroy
```
