# Organizze MCP

Local MCP server exposing the [Organizze API](https://github.com/organizze/api-doc) so Claude Code can help manage finances via `.md` files in this repo.

## Setup

1. Install Ruby 4.0 (see `.tool-versions`).
2. `bundle install`
3. Copy `.env.example` to `.env` and fill in:
   - `ORGANIZZE_EMAIL` — your account email
   - `ORGANIZZE_API_TOKEN` — from https://app.organizze.com.br/configuracoes/api-keys
   - `ORGANIZZE_USER_AGENT` — e.g. `Organizze-MCP (you@example.com)` (required by the API)
4. Restart Claude Code in this directory. It will pick up `.mcp.json` and prompt to approve the `organizze` server.

## Tools

- `get_user`
- `list_accounts`, `list_categories`, `list_credit_cards`, `list_transfers`
- `list_invoices` (requires `credit_card_id`)
- `list_transactions` (optional `start_date`, `end_date` — `YYYY-MM-DD`)
- `list_budgets` (requires `year`, `month`)
- `update_transaction_category` (the only write tool — changes a transaction's `category_id`)

## Run manually

```
bundle exec ruby bin/organizze-mcp
```

It speaks MCP over stdio.
