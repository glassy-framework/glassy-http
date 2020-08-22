require "glassy-kernel"

module Glassy::HTTP
  class Bundle < Glassy::Kernel::Bundle
    SERVICES_PATH = "#{__DIR__}/config/services.yml"
  end
end
