require "kemal"

module Glassy::HTTP
  abstract class Middleware < Kemal::Handler
    def name : String?
      nil
    end

    def priority
      # Lower is first
      100
    end

    def add_only(paths : Array(String), method : String) : Void
      class_name = {{@type.name}}
      method_downcase = method.downcase
      class_name_method = "#{class_name}/#{method_downcase}"

      paths.each do |path|
        @@only_routes_tree.add class_name_method + path, '/' + method_downcase + path
      end
    end
  end
end
