module Pmu

  class Engine < Rails::Engine

    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")
    config.i18n.load_path.unshift(*Dir[root.join("config", "locales", "**", "*.{rb,yml}").to_s])

    config.to_prepare do
      NufsAccount.send :include, Pmu::NufsAccountExtension
      GeneralReportsController.send :include, Pmu::GeneralReportsControllerExtension
      InstrumentReportsController.send :include, Pmu::InstrumentReportsControllerExtension
      ::Reports::ExportRaw.transformers << "Pmu::Reports::ExportRawTransformer"

      # make this engine's views override the main app's views
      paths = ActionController::Base.view_paths.to_a
      index = paths.find_index { |p| p.to_s.include? "pmu" }
      paths.unshift paths.delete_at(index)
      ActionController::Base.view_paths = paths
    end

  end

end
