require "kemal"

module Kemal
  class ParamParser
    @json_any_parsed : Bool?
    @json_any : JSON::Any?

    private def parse_json
      return if json_any.nil?

      case json = json_any.raw
      when Hash
        json.each do |key, value|
          @json[key] = value.raw
        end
      when Array
        @json["_json"] = json
      else
        # Ignore non Array or Hash json values
      end
    end

    def json_any
      return @json_any if @json_any_parsed
      parse_json_any
      @json_any_parsed = true
      @json_any
    end

    private def parse_json_any
      return unless @request.body && @request.headers["Content-Type"]?.try(&.starts_with?(APPLICATION_JSON))

      body = @request.body.not_nil!.gets_to_end

      @json_any = JSON.parse(body)
    end
  end
end
