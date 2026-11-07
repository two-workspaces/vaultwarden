# Deploy and Host Vaultwarden on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/vaultwarden-server?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=vaultwarden-server)

Vaultwarden is a lightweight server for the Bitwarden password manager. It works with the official Bitwarden apps, browser extensions and CLI, and serves its own web vault. This template runs Vaultwarden 1.37.5 on Railway with sign-ups closed, a hashed admin password, and a volume that keeps your vault across redeploys.

This is a community template, not made or supported by the Vaultwarden or Bitwarden projects.

## About Hosting Vaultwarden

Out of the box, Vaultwarden lets anyone who finds its address create an account. On a public Railway domain that means strangers can sign up on your server. This template sets `SIGNUPS_ALLOWED=false`, so only people you invite can register.

**First account:** put your email in `OWNER_EMAIL` when you deploy. On first boot the server invites that address, and you create your account at `https://<your-domain>/#/signup` with that email. Without email sending set up, an invited address registers directly, with no link to click. If you left `OWNER_EMAIL` empty, open `https://<your-domain>/admin`, sign in with `ADMIN_PASSWORD`, and invite yourself under **Users**.

**Admin panel:** `/admin` is protected by `ADMIN_PASSWORD`, which the template generates. It's turned into an Argon2id hash at boot, so the app never holds it in plain text. Find the password in the service's **Variables** tab.

**Your data:** the SQLite database, attachments and keys live on a volume at `/data`. After signing up, point any Bitwarden app at your domain: choose **Self-hosted** on the login screen and enter `https://<your-domain>`.

## Common Use Cases

- A private password vault for yourself, synced across phone, browser and desktop
- Shared passwords for a family or a small team through organizations and collections
- A Bitwarden-compatible server you control, without per-user licences

## Dependencies for Vaultwarden Hosting

- None. The web vault and database are included. Email sending (SMTP) is optional.

### Deployment Dependencies

- [Vaultwarden on GitHub](https://github.com/dani-garcia/vaultwarden)
- [Vaultwarden wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [Bitwarden apps and extensions](https://bitwarden.com/download/)
- [Template source](https://github.com/two-workspaces/vaultwarden)

### Implementation Details

- **Tested on Railway:** the first-boot invite, sign-up as the invited owner, login, a stranger's sign-up being refused, admin login with the generated password, and the vault and keys surviving a redeploy. Logs show each client's real IP, which login rate limits rely on.
- **Inviting others:** from `/admin` under **Users**, or from an organization in the web vault. Without SMTP, invited people register at `/#/signup` with the invited email.
- **Email (optional):** add `SMTP_HOST`, `SMTP_FROM`, `SMTP_PORT`, `SMTP_SECURITY` (`starttls`, `force_tls` or `off`), `SMTP_USERNAME` and `SMTP_PASSWORD` to send invitations, email 2FA codes and new-device alerts. Once SMTP is set, invited people get a link by email instead of registering directly.
- **Admin password changes:** edit `ADMIN_PASSWORD` and redeploy. Once you click **Save** in the admin settings, Vaultwarden keeps its settings in `/data/config.json`, and those take priority over variables, including the admin token. After that, change the token in the admin settings instead.
- **Mobile push:** instant sync on phones needs a free installation ID and key from [bitwarden.com/host](https://bitwarden.com/host/), set as `PUSH_ENABLED=true`, `PUSH_INSTALLATION_ID` and `PUSH_INSTALLATION_KEY`. Without them, apps still sync on open and on pull-to-refresh.
- **Backups:** turn on volume backups in the service's **Backups** tab. A vault is the kind of data you want a copy of.
- **Image:** upstream's `vaultwarden/server:1.37.5`, pinned, plus a small boot script that hashes the admin password and sends the first invite.

## Why Deploy Vaultwarden on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Vaultwarden on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
