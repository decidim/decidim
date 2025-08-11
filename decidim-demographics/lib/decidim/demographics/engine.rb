# frozen_string_literal: true

module Decidim
  module Demographics
    # This is the engine that runs on the public interface of `decidim-demographics`.
    # It handles the interaction between participant and own demographic data
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Demographics

      routes do
        resource :demographics, only: [:show, :respond, :destroy] do
          collection do
            post :respond
          end
        end
      end

      initializer "decidim_demographics.register_admin" do
        Decidim::Core::Engine.routes do
          mount Decidim::Demographics::Engine => "/", :as => :demographics_engine
        end
      end

      initializer "decidim_demographics.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.add_item :demographics,
                        t("name", scope: "decidim.demographics"),
                        demographics_engine.demographics_path,
                        position: 1.0,
                        active: is_active_link?(demographics_engine.demographics_path)

          menu.move :demographics, after: :download_your_data
        end
      end

      initializer "decidim_demographics.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
