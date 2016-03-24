module Jxml

  class Engine < Rails::Engine

    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")

    config.to_prepare do
      # make this engine's views override the main app's views
      paths = ActionController::Base.view_paths.to_a
      index = paths.find_index { |p| p.to_s.include? "jxml" }
      paths.unshift paths.delete_at(index)
      ActionController::Base.view_paths = paths
    end

  end

end
