require "nucore/engine_config"

module Nucore

  class Application < Rails::Application

    include Nucore::EngineConfig

  end

end
