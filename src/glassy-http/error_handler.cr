require "http/server"
require "log"
require "kemal"
require "./exceptions/*"

module Glassy::HTTP
  class ErrorHandler < Kemal::Handler
    def call(ctx : ::HTTP::Server::Context)
      begin
        call_next(ctx)
      rescue e : Exception
        handle_error(ctx, e)
      end
    end

    def handle_error(ctx : ::HTTP::Server::Context, exception : Exception)
      Log.error(exception: exception) { exception.message }
      ctx.response.status_code = get_status_code(exception)
      ctx.response.content_type = get_content_type(exception)
      ctx.response.print format_exception(exception)
    end

    def format_exception(exception : Exception)
      get_error_message(exception)
    end

    def get_error_message(exception : Exception) : String
      case exception
      when Glassy::HTTP::Exceptions::HTTPException
        exception.message || "Error"
      when Kemal::Exceptions::RouteNotFound
        "Not found"
      else
        "Internal Server Error"
      end
    end

    def get_status_code(exception : Exception) : Int32
      case exception
      when Glassy::HTTP::Exceptions::HTTPException
        exception.status_code
      when Kemal::Exceptions::RouteNotFound
        404
      else
        500
      end
    end

    def get_content_type(exception : Exception) : String
      "text/html"
    end
  end
end
