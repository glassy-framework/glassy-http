require "./spec_helper"

class MyController < Glassy::HTTP::Controller
  @[Route("GET", "/example")]
  def example
    "Hello World!"
  end

  @[Route("GET", "/echo")]
  @[Context(arg: "ctx")]
  def example(ctx : HTTP::Server::Context)
    ctx.params.query["name"]
  end
end

controller = MyController.new
controller.register_routes

Kemal.run

describe Glassy::Http do
  it "map requests" do
    get "/example"
    response.body.should eq "Hello World!"

    get "/echo?name=Test"
    response.body.should eq "Test"
  end
end
