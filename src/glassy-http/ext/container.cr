require "../controller"
require "../middleware"

module Glassy::Kernel
  abstract class Container
    abstract def controller_list : Array(Glassy::HTTP::Controller)
    abstract def route_middleware_list : Array(Glassy::HTTP::Middleware)
  end
end
