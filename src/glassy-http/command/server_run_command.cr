require "glassy-console"
require "../ext/container"
require "kemal"

module Glassy::HTTP::Command
  class ServerRunCommand < Glassy::Console::Command
    property name : String = "server:run"
    property description : String = "run HTTP server"

    def initialize(
      input : Input,
      output : Output,
      @container : Glassy::Kernel::Container,
      @http_kernel : Glassy::HTTP::Kernel
    )
      super(input, output)
    end

    @[Option(name: "port", desc: "Listen to port")]
    def execute(port : Int?)
      unless port.nil?
        Kemal.config.port = port
      end

      @http_kernel.register_controllers(@container.http_controller_builder_list)
      @http_kernel.register_middlewares(@container.http_middleware_list)
      @http_kernel.run
    end
  end
end
