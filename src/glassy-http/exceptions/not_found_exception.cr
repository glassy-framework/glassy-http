require "./http_exception"

module Glassy::HTTP::Exceptions
  class NotFoundException < HTTPException
    def initialize(message : String)
      super(404, message)
    end
  end
end
