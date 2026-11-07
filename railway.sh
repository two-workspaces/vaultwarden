# Sourced by the upstream /start.sh right before it execs /vaultwarden.

# Railway routes the public domain to $PORT.
export ROCKET_PORT="${PORT:-8080}"

# ADMIN_PASSWORD (a template secret) becomes an Argon2id ADMIN_TOKEN, with the
# OWASP preset Vaultwarden's own `hash` command uses. A fresh salt each boot is
# fine: the token is only compared, never stored.
if [ -n "${ADMIN_PASSWORD:-}" ] && [ -z "${ADMIN_TOKEN:-}" ]; then
  ADMIN_TOKEN="$(printf '%s' "$ADMIN_PASSWORD" | argon2 "$(openssl rand -base64 32)" -e -id -k 19456 -t 2 -p 1)"
  export ADMIN_TOKEN
fi

# Sign-ups are closed, so the owner needs an invitation to create an account.
# With OWNER_EMAIL set, invite it once through the admin API after the server
# is up. Without SMTP, an invited address can register straight from the web
# vault. The marker keeps this to the first successful boot.
if [ -n "${OWNER_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ] && [ ! -e /data/.owner-invited ]; then
  (
    base="http://127.0.0.1:${ROCKET_PORT}"
    jar=/tmp/vw-admin.cookies
    for _ in $(seq 1 120); do
      curl -fsS -o /dev/null "$base/alive" 2>/dev/null && break
      sleep 1
    done
    if curl -fsS -o /dev/null -c "$jar" --data-urlencode "token=$ADMIN_PASSWORD" "$base/admin" &&
       code=$(curl -sS -o /tmp/vw-invite.out -w '%{http_code}' -b "$jar" -H 'Content-Type: application/json' \
              --data "{\"email\":\"$OWNER_EMAIL\"}" "$base/admin/invite") &&
       { [ "$code" = 200 ] || grep -qi 'already exists' /tmp/vw-invite.out; }; then
      touch /data/.owner-invited
      echo "[railway] invited $OWNER_EMAIL: create your account at $DOMAIN/#/signup"
    else
      echo "[railway] could not invite OWNER_EMAIL (HTTP ${code:-none}); invite yourself from $DOMAIN/admin"
    fi
    rm -f "$jar" /tmp/vw-invite.out
  ) &
fi
