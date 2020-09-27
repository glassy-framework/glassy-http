module Glassy::HTTP::Exceptions
  abstract class HTTPException < Exception
    property status_code : Int32

    def initialize(@status_code, message)
      super(message)
    end
  end
end

