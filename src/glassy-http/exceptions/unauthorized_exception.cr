require "./http_exception"

module Glassy::HTTP::Exceptions
  class UnauthorizedException < HTTPException
    def initialize(message : String)
      super(401, message)
    end
  end
end
