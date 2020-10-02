require "./annotations"
require "kemal"
require "./middleware"
require "./kernel"

module Glassy::HTTP
  abstract class Controller
    include Glassy::HTTP::Annotations

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

    private def dig_json(json : JSON::Any?, path : String) : JSON::Any?
      return if json.nil?

      pieces = path.split(".")
      result = json

      while next_piece = pieces.shift?
        if !result.nil? && result[next_piece]?
          result = result[next_piece]
        else
          result = nil
        end
      end

      result
    end

    macro inherited
      generate_inherited_macro

      macro finished
        generate_methods \{{@type}}
      end
    end

    macro generate_inherited_macro
      {% if @type.abstract? %}
        macro inherited
          generate_inherited_macro

          macro finished
            generate_methods \{{@type}}
          end
        end
      {% end %}
    end

    macro generate_methods(type_path)
      {% type = type_path.resolve %}

      {% unless type.abstract? %}
        def register_routes(
          http_kernel : Glassy::HTTP::Kernel,
          middlewares_by_name : Hash(String, Glassy::HTTP::Middleware)
        )
          {% types = [type] %}
          {% for type_anc in type.ancestors %}
            {% if type_anc.name =~ /Controller/ %}
              {% types << type_anc %}
            {% end %}
          {% end %}

          {% for type_unit in types %}
            {% for method in type_unit.methods %}
              {% route_ann = method.annotation(Route) %}
              {% if route_ann %}
                path = "#{path_prefix}{{route_ann[1].id}}".sub(/(.+)\/$/, "\\1")
                method = {{route_ann[0]}}

                http_kernel.add_route(method, path) do |ctx|
                  {% args = [] of StringLiteral %}

                  {% ann = method.annotation(Context) %}
                  {% if ann %}
                    {% args << "#{ann[:arg].id}: ctx" %}
                  {% end %}

                  {% for ann in method.annotations(JSONBody) %}
                    {% if ann %}
                      {% value = "ctx.params.json_any" %}

                      {% if ann[:path] %}
                        {% value = "dig_json(#{value.id}, #{ann[:path]})" %}
                      {% end %}

                      {% if ann[:required] %}
                        if {{value.id}}.nil?
                          {% if ann[:path] %}
                            raise Glassy::HTTP::Exceptions::BadRequestException.new("JSON path {{ann[:path].id}} can't be empty")
                          {% else %}
                            raise Glassy::HTTP::Exceptions::BadRequestException.new("JSON body can't be empty")
                          {% end %}
                        end

                        {% value = "#{value.id}.not_nil!" %}
                      {% end %}

                      {% args << "#{ann[:arg].id}: #{value.id}" %}
                    {% end %}
                  {% end %}

                  {% ann = method.annotation(ContentType) %}
                  {% if ann %}
                    ctx.response.content_type = {{ann[0]}}
                  {% end %}

                  {{method.name}}({{args.join(", ").id}})
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
      {% end %}
    end
  end
end
