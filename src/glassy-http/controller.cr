require "./annotations"
require "kemal"

module Glassy::HTTP
  class Controller
    alias Route = Glassy::HTTP::Annotations::Route
    alias Context = Glassy::HTTP::Annotations::Context

    macro inherited
      macro finished
        def register_routes
          {% verbatim do %}
            {% for method in @type.methods %}
              {% route_ann = method.annotation(Route) %}
              {% if route_ann %}
                Kemal::RouteHandler::INSTANCE.add_route(
                  {{route_ann[0]}},
                  {{route_ann[1]}}
                ) do |ctx|
                  {{method.name}}(
                    {% ctx_ann = method.annotation(Context) %}
                    {% if ctx_ann %}
                      {{ctx_ann[:arg].id}}: ctx,
                    {% end %}
                  )
                end
              {% end %}
            {% end %}
          {% end %}
        end
      end
    end
  end
end
