require "json"
require "semantic_version"

module Swagger::HTTP
  class APIHandler
    include Swagger::HTTP::Handler

    @swagger_path : String
    @json : String

    def initialize(document : Document, @endpoint : String, swagger_path : String? = nil, @debug_mode = false)
      major = SemanticVersion.parse(document.openapi_version).major

      @swagger_path = swagger_path.is_a?(String) ? swagger_path : "/v#{major}/swagger.json"
      @json = document.to_json

      puts "[WARN] Swagger APIHandler debug mode was enabled" if @debug_mode
    end

    def call(context)
      return call_next(context) unless match?(context)

      context.response.headers["Access-Control-Allow-Origin"] = "*" if @debug_mode
      response_with(context, @json)
    end

    def match?(context)
      match_router?(context, @swagger_path)
    end

    def api_url
      uri = URI.parse(@endpoint)
      uri.path = @swagger_path
      uri.to_s
    end
  end
end
