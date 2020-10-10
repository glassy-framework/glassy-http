require "../controller"
require "../middleware"

module Glassy::Kernel
  abstract class Container
    abstract def http_controller_list : Array(Glassy::HTTP::Controller)
    abstract def http_controller_builder_list : Array(Glassy::Kernel::Builder(Glassy::HTTP::Controller))
    abstract def http_middleware_list : Array(Glassy::HTTP::Middleware)
  end
end
