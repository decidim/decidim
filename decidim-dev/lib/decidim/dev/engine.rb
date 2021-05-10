# frozen_string_literal: true

module Decidim
  module Dev
    # Decidim's development Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Dev
      engine_name "decidim_dev"

      initializer "decidim_dev.tools" do |app|
        ActiveSupport.on_load :action_controller do
          ActionController::Base.include Decidim::Dev::NeedsDevelopmentTools
        end
      end
    end
  end
end
