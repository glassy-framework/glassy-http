require "glassy-console"
require "../ext/container"
require "kemal"

module Glassy::HTTP::Command
  class ServerRunCommand < Glassy::Console::Command
    property name : String = "server:run"
    property description : String = "run HTTP server"

    def initialize(input : Input, output : Output, container : Glassy::Kernel::Container)
      @container = container
      super.initialize(input, output)
    end

    def execute
      container.controller_list.each do |ctrl|
        ctrl.register_routes
      end

      Kemal.run
    end
  end
end
