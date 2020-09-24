require "./annotations"
require "kemal"
require "./middleware"
require "./kernel"

module Glassy::HTTP
  abstract class Controller
    alias Route = Glassy::HTTP::Annotations::Route
    alias Context = Glassy::HTTP::Annotations::Context

    abstract def register_routes(
      http_kernel : Glassy::HTTP::Kernel,
      middlewares_by_name : Hash(String, Glassy::HTTP::Middleware)
    )

    def path_prefix : String
      return ""
    end

    def middlewares : Array(String)
      return [] of String
    end

    macro inherited
      macro finished
        def register_routes(
          http_kernel : Glassy::HTTP::Kernel,
          middlewares_by_name : Hash(String, Glassy::HTTP::Middleware)
        )
          {% verbatim do %}
            {% for method in @type.methods %}
              {% route_ann = method.annotation(Route) %}
              {% if route_ann %}
                path = "#{path_prefix}{{route_ann[1].id}}"
                method = {{route_ann[0]}}

                http_kernel.add_route(method, path) do |ctx|
                  {{method.name}}(
                    {% ctx_ann = method.annotation(Context) %}
                    {% if ctx_ann %}
                      {{ctx_ann[:arg].id}}: ctx,
                    {% end %}
                  )
                end

                middlewares.each do |middleware_name|
                  middleware = middlewares_by_name[middleware_name]?
                  if middleware
                    middleware.add_only([path], method)
                  else
                    raise "Middleware #{middleware_name} is not defined"
                  end
                end

                {% if route_ann[:middlewares] %}
                  {% for middleware in route_ann[:middlewares] %}
                    middleware = middlewares_by_name[{{middleware}}]?

                    if middleware
                      middleware.add_only([path], method)
                    else
                      raise "Middleware {{middleware.id}} is not defined"
                    end
                  {% end %}
                {% end %}
              {% end %}
            {% end %}
          {% end %}
        end
      end
    end
  end
end
