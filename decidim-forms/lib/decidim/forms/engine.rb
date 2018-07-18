# frozen_string_literal: true

module Decidim
  module Forms
    # This is the engine that runs on the public interface of `decidim-forms`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Forms

      initializer "decidim_forms.assets" do |app|
        app.config.assets.precompile += %w(decidim_forms_manifest.js)
      end
    end
  end
end
