# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Personal finance workspace. Two concerns live here:

1. A local **MCP server** (`bin/organizze-mcp`) that wraps the [Organizze API](https://github.com/organizze/api-doc) so this Claude Code session can read the user's financial data.
2. Markdown files authored by the user (with Claude's help) that analyze/summarize that data.

The MCP is mostly read-only. The only write tool is `UpdateTransactionCategory` (PUT /transactions/:id with category_id). Do not add other write tools (create/delete transactions, mutate accounts, etc.) without explicit user approval.

## Commands

```bash
bundle install                      # install gems (first time / after Gemfile changes)
bundle exec ruby bin/organizze-mcp  # run the MCP server manually (speaks JSON-RPC over stdio)
```

There are no tests or linters configured yet. The server is invoked automatically by Claude Code via `.mcp.json` — users don't run it by hand during normal use.

## Architecture

- `lib/organizze/client.rb` — minimal `Net::HTTP` wrapper. Basic auth (email + token), sets the mandatory `User-Agent` header, parses JSON. One public method: `#get(path, query = {})`.
- `lib/organizze/server.rb` — defines one `MCP::Tool` subclass per endpoint, a module-level `CLIENT` singleton built from env vars, and `Organizze.run` which wires tools into `MCP::Server` over `StdioTransport`. Tool `call` methods take the schema's properties as keyword args plus `server_context:` and return `MCP::Tool::Response.new([{type: "text", text: ...}])`.
- `bin/organizze-mcp` — tiny entry point: `require` the server and call `Organizze.run`.

Adding a new endpoint = add one `MCP::Tool` subclass in `server.rb` and include it in the `tools:` array in `Organizze.run`. Keep that pattern; don't introduce registries or metaprogramming.

## Configuration

Credentials come from `.env` (gitignored):

- `ORGANIZZE_EMAIL` — account email
- `ORGANIZZE_API_TOKEN` — from https://app.organizze.com.br/configuracoes/api-keys
- `ORGANIZZE_USER_AGENT` — e.g. `Organizze-MCP (you@example.com)` — **required by the API**; requests without it get a 400.

`.mcp.json` registers the server with Claude Code. `.claude/settings.json` pre-approves `Edit`, `Write`, `MultiEdit`, `NotebookEdit`, and `WebFetch` for this repo.

## Style

User has asked for the simplest possible code. Prefer stdlib (`Net::HTTP`, `json`) over adding gems. Avoid abstractions, DSLs, or speculative options. One file per concern is fine — don't split further unless it clearly pays off.
