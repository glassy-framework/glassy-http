require "glassy-kernel"
require "./command/server_run_command"

module Glassy::HTTP
  class Bundle < Glassy::Kernel::Bundle
    SERVICES_PATH = "#{__DIR__}/config/services.yml"
  end
end
