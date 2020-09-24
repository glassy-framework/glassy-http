require "http/server"
require "kemal"
require "json"
require "./controller"
require "./middleware"

module Glassy::HTTP
  class Kernel
    @middlewares : Array(Middleware)

    def initialize(@error_handler : ErrorHandler)
      @controllers = [] of Controller
      @middlewares = [] of Middleware
    end

    def add_route(method : String, path : String, &action : Proc(::HTTP::Server::Context, JSON::Any::Type))
      Kemal::RouteHandler::INSTANCE.add_route(method, path) do |ctx|
        action.call(ctx)
      end
    end

    def register_controllers(controllers : Array(Controller))
      @controllers = controllers.map do |controller|
        controller.as(Controller)
      end
    end

    def register_middlewares(middlewares : Array(Middleware))
      @middlewares = middlewares.map do |controller|
        controller.as(Middleware)
      end
    end

    def run
      add_handler @error_handler

      @middlewares.sort_by(&.priority).each do |middleware|
        add_handler middleware
      end

      middlewares_by_name = @middlewares
        .reject(&.name.nil?)
        .group_by(&.name.as(String))
        .transform_values(&.first)

      @controllers.each do |controller|
        controller.register_routes(self, middlewares_by_name)
      end

      Kemal.run
    end
  end
end
