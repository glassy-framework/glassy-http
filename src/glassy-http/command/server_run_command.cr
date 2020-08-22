require "glassy-console"
require "../ext/container"
require "kemal"

module Glassy::HTTP::Command
  class ServerRunCommand < Glassy::Console::Command
    property name : String = "server:run"
    property description : String = "run HTTP server"

    def initialize(input : Input, output : Output, container : Glassy::Kernel::Container)
      @container = container

      super(input, output)
    end

    @[Option(name: "port", desc: "Listen to port")]
    def execute(port : Int?)
      unless port.nil?
        Kemal.config.port = port
      end

      @container.controller_list.each do |ctrl|
        ctrl.register_routes
      end

      Kemal.run
    end
  end
end
