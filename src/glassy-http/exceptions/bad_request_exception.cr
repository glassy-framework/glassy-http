require "./http_exception"

module Glassy::HTTP::Exceptions
  class BadRequestException < HTTPException
    def initialize(message : String)
      super(400, message)
    end
  end
end
