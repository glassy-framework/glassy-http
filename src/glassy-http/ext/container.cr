require "../controller"

module Glassy::Kernel
  abstract class Container
    abstract def controller_list : Array(Glassy::HTTP::Controller)
  end
end
