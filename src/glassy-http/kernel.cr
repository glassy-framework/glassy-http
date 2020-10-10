require "http/server"
require "kemal"
require "json"
require "./controller"
require "./middleware"

module Glassy::HTTP
  class Kernel
    @middlewares : Array(Middleware)

    def initialize(@error_handler : ErrorHandler)
      @controller_builders = [] of Glassy::Kernel::Builder(Controller)
      @middlewares = [] of Middleware
    end

    def add_route(method : String, path : String, &action : Proc(::HTTP::Server::Context, JSON::Any::Type))
      Kemal::RouteHandler::INSTANCE.add_route(method, path) do |ctx|
        action.call(ctx)
      end
    end

    def register_controllers(controller_builders : Array(Glassy::Kernel::Builder(Controller)))
      @controller_builders = controller_builders
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
        .group_by(&.name.not_nil!.as(String))
        .transform_values(&.first)

      @controller_builders.each do |controller_builder|
        sample_controller = controller_builder.make

        sample_controller.register_routes(self, middlewares_by_name, controller_builder)
      end

      Kemal.run
    end
  end
end
