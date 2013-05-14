module NuCancerCenter
  class Engine < Rails::Engine
    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")

    config.to_prepare do
      User.send :include, NuCancerCenter::UserExtension
    end
  end
end
