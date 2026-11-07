FROM vaultwarden/server:1.37.5

# argon2 hashes ADMIN_PASSWORD into ADMIN_TOKEN at boot, so the token Vaultwarden
# holds is never the plain password (it warns about plain tokens on /admin).
RUN apt-get update && apt-get install -y --no-install-recommends argon2 && \
    rm -rf /var/lib/apt/lists/*

# start.sh sources /etc/vaultwarden.d/*.sh before exec'ing the server.
COPY railway.sh /etc/vaultwarden.d/railway.sh
