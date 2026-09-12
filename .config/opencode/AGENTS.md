# Global Rules

## Notifications
When asked to notify, send a Telegram message using:
`echo "message" | ~/.scripts/ntfy.sh`

The script reads from stdin and sends to Telegram via bot API.
Use this when tasks complete, when you need to alert the user, or when explicitly asked to notify.
