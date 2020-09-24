require "./spec_helper"

class MyController < Glassy::HTTP::Controller
  @[Route("GET", "/example")]
  def example
    "Hello World!"
  end

  def path_prefix
    "/prefix"
  end

  def middlewares
    ["test-controller-middleware"]
  end

  @[Route("GET", "/echo")]
  @[Context(arg: "ctx")]
  def example(ctx : HTTP::Server::Context)
    ctx.params.query["name"]
  end

  @[Route("GET", "/error-route")]
  def error_route
    raise "Error Test"
  end

  @[Route("GET", "/custom-error-route")]
  def custom_error_route
    raise CustomException.new("Error Test")
  end

  @[Route("GET", "/route-with-middleware", middlewares: ["test-middle"])]
  def route_with_middleware
    "Ok, Ok"
  end
end

class CustomException < Exception
end

class CustomErrorHandler < Glassy::HTTP::ErrorHandler
  def get_error_message(exception : Exception) : String
    case exception
    when CustomException
      exception.message || "No message"
    else
      super
    end
  end

  def get_status_code(exception : Exception) : Int32
    case exception
    when CustomException
      400
    else
      super
    end
  end
end

class TestMiddleware < Glassy::HTTP::Middleware
  def name : String
    "test-middle"
  end

  def call(env)
    return call_next(env) unless only_match?(env)

    env.response.headers.add("My-Test", "Yes, My Test")
    call_next(env)
  end
end

class TestControllerMiddleware < Glassy::HTTP::Middleware
  def name : String
    "test-controller-middleware"
  end

  def call(env)
    return call_next(env) unless only_match?(env)

    env.response.headers.add("My-Ctrl-Test", "Ctrl")
    call_next(env)
  end
end

error_handler = CustomErrorHandler.new

http_kernel = Glassy::HTTP::Kernel.new(error_handler)
http_kernel.register_controllers([MyController.new])
http_kernel.register_middlewares([TestMiddleware.new, TestControllerMiddleware.new])
http_kernel.run

describe Glassy::HTTP::Controller do
  it "map requests" do
    get "/prefix/example"
    response.body.should eq "Hello World!"
    response.headers["My-Test"]?.should be_nil
    response.headers["My-Ctrl-Test"]?.should eq "Ctrl"

    get "/prefix/echo?name=Test"
    response.body.should eq "Test"
    response.headers["My-Test"]?.should be_nil
    response.headers["My-Ctrl-Test"]?.should eq "Ctrl"

    get "/prefix/error-route"
    response.body.should eq "Internal Server Error"
    response.status_code.should eq 500
    response.content_type.should eq "text/html"
    response.headers["My-Ctrl-Test"]?.should eq "Ctrl"

    get "/prefix/custom-error-route"
    response.body.should eq "Error Test"
    response.status_code.should eq 400
    response.headers["My-Ctrl-Test"]?.should eq "Ctrl"

    get "/prefix/route-with-middleware"
    response.body.should eq "Ok, Ok"
    response.status_code.should eq 200
    response.headers["My-Test"]?.should eq "Yes, My Test"
    response.headers["My-Ctrl-Test"]?.should eq "Ctrl"

    get "/prefix/not-found-route"
    response.status_code.should eq 404
    response.body.should eq "Not found"
  end
end
