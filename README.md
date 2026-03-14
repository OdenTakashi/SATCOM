# SATCOM

A tiny LINE bot that helps you prepare for month-end peace.

## How It Works

Send `/<amount>` to record an expense, send `/` to see the summary.

Billing period starts on the 25th of each month.

### Example

```
You:  /500
Bot:  500円の立替、記録したぜ。オーバー!

You:  /1200
Bot:  1200円の立替、記録したぜ。オーバー!

You:  /
Bot:  --- 集計 (02/25〜) ---
      たかし: 28300円
      はなこ: 29000円
      オーバー!
```

## Commands

| Command | Description |
|---------|-------------|
| `/<amount>` | Record an expense (e.g. `/500`) |
| `/` | Show monthly summary (remaining budget per member) |

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | Rails 8.1 |
| Ruby | 4.0.1 |
| Database | SQLite3 |
| LINE SDK | line-bot-api v2 |
| Deploy | Fly.io (Docker) |

## Setup

### Prerequisites

- Ruby 4.0.1
- LINE Messaging API channel (LINE Developers Console)

### Local Development

```bash
git clone <repo-url>
cd SATCOM
bin/setup
# Edit .env with your credentials
```

### Run Tests

```bash
bin/rails test
```

### Start Server

```bash
bin/rails server
curl http://localhost:3000/up  # Health check
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `LINE_CHANNEL_TOKEN` | Yes | LINE Messaging API channel access token |
| `LINE_CHANNEL_SECRET` | Yes | LINE Messaging API channel secret |

## Architecture

```
LINE App -> POST /callback
  -> WebhookController
    -> Parse & verify signature
      -> RecordPaymentCommand (/<amount>)  -> Save to DB -> reply
      -> SummaryCommand (/)                -> Query DB   -> reply
```

## Deploy

```bash
fly deploy
```

SQLite data is stored on a Fly.io persistent volume (`satcom_data`), so data persists across deploys.

## License

MIT
