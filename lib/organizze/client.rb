require "net/http"
require "json"

module Organizze
  class Client
    BASE = "https://api.organizze.com.br/rest/v2".freeze

    def initialize(email:, token:, user_agent:)
      @email = email
      @token = token
      @user_agent = user_agent
    end

    def get(path, query = {})
      uri = URI("#{BASE}#{path}")
      uri.query = URI.encode_www_form(query.compact) unless query.empty?
      request(Net::HTTP::Get.new(uri), uri)
    end

    def put(path, body)
      uri = URI("#{BASE}#{path}")
      req = Net::HTTP::Put.new(uri)
      req["Content-Type"] = "application/json"
      req.body = JSON.generate(body)
      request(req, uri)
    end

    private

    def request(req, uri)
      req.basic_auth(@email, @token)
      req["User-Agent"] = @user_agent
      req["Accept"] = "application/json"

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }
      raise "Organizze API #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)

      JSON.parse(res.body)
    end
  end
end
