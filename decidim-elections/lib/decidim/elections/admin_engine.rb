# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface of `Elections`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        get "/answer_options", to: "feedback_forms#answer_options", as: :answer_options_election_feedback, defaults: { format: "json" }

        resources :elections do
          resources :steps, only: [:index, :update] do
            get :stats
          end
          member do
            put :publish
            put :unpublish
            resource :feedback_form, only: [:edit, :update] do
              collection do
                get :answers, to: "feedback_forms#index"
                get "/answer/:session_token", to: "feedback_forms#show", as: :answer
                get "/answer/:session_token/export", to: "feedback_forms#export_response", as: :answer_export
              end
            end
          end
          resources :questions do
            resources :answers do
              collection do
                get :proposals_picker
                resource :proposals_import, only: [:new, :create]
              end
              member do
                put :select
                put :unselect
              end
            end
          end
        end

        resources :trustees, only: [:index, :new, :edit, :create, :destroy], controller: "trustees_participatory_spaces"

        root to: "elections#index"
      end

      def self.participatory_space_endpoints
        [:trustees]
      end

      initializer "decidim_admin_elections.menu_entry" do
        Decidim.participatory_space_registry.manifests.each do |participatory_space|
          menu_id = :"admin_#{participatory_space.name.to_s.singularize}_menu"
          Decidim.menu menu_id do |menu|
            component = current_participatory_space.try(:components)&.find_by(manifest_name: :elections)
            next unless component

            link = Decidim::EngineRouter.admin_proxy(component).trustees_path(locale: I18n.locale)
            menu.add_item :trustees,
                          I18n.t("trustees", scope: "decidim.elections.admin.menu"),
                          link,
                          position: 100,
                          if: allowed_to?(:manage, :trustees),
                          active: is_active_link?(link)
          end
        end
      end

      initializer "decidim_elections.assets" do |app|
        app.config.assets.precompile += %w(decidim_elections_manifest.js decidim_elections_manifest.css)
      end

      def load_seed
        nil
      end
    end
  end
end
