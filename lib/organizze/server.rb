require "mcp"
require "mcp/server/transports/stdio_transport"
require "dotenv/load"
require "json"
require_relative "client"

module Organizze
  CLIENT = Client.new(
    email: ENV.fetch("ORGANIZZE_EMAIL"),
    token: ENV.fetch("ORGANIZZE_API_TOKEN"),
    user_agent: ENV.fetch("ORGANIZZE_USER_AGENT")
  )

  def self.respond(data)
    MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(data) }])
  end

  class GetUser < MCP::Tool
    description "Get the current Organizze user profile."
    input_schema(properties: {})
    def self.call(server_context:)
      Organizze.respond(CLIENT.get("/users"))
    end
  end

  class ListAccounts < MCP::Tool
    description "List all bank accounts."
    input_schema(properties: {})
    def self.call(server_context:)
      Organizze.respond(CLIENT.get("/accounts"))
    end
  end

  class ListCategories < MCP::Tool
    description "List all transaction categories."
    input_schema(properties: {})
    def self.call(server_context:)
      Organizze.respond(CLIENT.get("/categories"))
    end
  end

  class ListCreditCards < MCP::Tool
    description "List all credit cards."
    input_schema(properties: {})
    def self.call(server_context:)
      Organizze.respond(CLIENT.get("/credit_cards"))
    end
  end

  class ListInvoices < MCP::Tool
    description "List invoices for a credit card. Requires credit_card_id."
    input_schema(
      properties: { credit_card_id: { type: "integer" } },
      required: ["credit_card_id"]
    )
    def self.call(credit_card_id:, server_context:)
      Organizze.respond(CLIENT.get("/credit_cards/#{credit_card_id}/invoices"))
    end
  end

  class ListTransactions < MCP::Tool
    description "List transactions. Accepts optional start_date and end_date (YYYY-MM-DD)."
    input_schema(
      properties: {
        start_date: { type: "string", description: "YYYY-MM-DD" },
        end_date: { type: "string", description: "YYYY-MM-DD" }
      }
    )
    def self.call(server_context:, start_date: nil, end_date: nil)
      Organizze.respond(CLIENT.get("/transactions", start_date: start_date, end_date: end_date))
    end
  end

  class UpdateTransactionCategory < MCP::Tool
    description "Update the category of a transaction. Requires transaction_id and category_id."
    input_schema(
      properties: {
        transaction_id: { type: ["integer", "string"] },
        category_id: { type: ["integer", "string"] }
      },
      required: ["transaction_id", "category_id"]
    )
    def self.call(transaction_id:, category_id:, server_context:)
      Organizze.respond(CLIENT.put("/transactions/#{transaction_id.to_i}", category_id: category_id.to_i))
    end
  end

  class ListBudgets < MCP::Tool
    description "List budgets for a given year and month."
    input_schema(
      properties: {
        year: { type: "integer" },
        month: { type: "integer" }
      },
      required: ["year", "month"]
    )
    def self.call(year:, month:, server_context:)
      Organizze.respond(CLIENT.get("/budgets/#{year}/#{month}"))
    end
  end

  class ListTransfers < MCP::Tool
    description "List transfers between accounts."
    input_schema(properties: {})
    def self.call(server_context:)
      Organizze.respond(CLIENT.get("/transfers"))
    end
  end

  def self.run
    server = MCP::Server.new(
      name: "organizze",
      tools: [
        GetUser, ListAccounts, ListCategories, ListCreditCards,
        ListInvoices, ListTransactions, ListBudgets, ListTransfers,
        UpdateTransactionCategory
      ]
    )
    MCP::Server::Transports::StdioTransport.new(server).open
  end
end
