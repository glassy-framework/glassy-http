require "./glassy-http/**"

# Fix kemal 0.26.1 on crystal 0.35.1
require "gzip"
require "flate"

module Glassy::Http
  VERSION = "0.1.0"
end
