# frozen_string_literal: true

module Decidim
  module Demographics
    # This is the engine that runs on the public interface of `decidim-debates`.
    # It mostly handles rendering the created debate associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Demographics::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :demographics, only: [:index] do
          collection do
            resource :settings, only: [:show, :update]

            resource :questions, only: [:edit_questions, :update_questions] do
              collection do
                get :edit_questions
                patch :update_questions
              end
            end

            resources :responses, only: [:index, :show] do
              member do
                get :export_response
              end
            end
            resources :publish_responses, only: [:index]
          end
        end
      end

      initializer "decidim_admin_demographics.register_admin" do
        Decidim::Admin::Engine.routes do
          mount Decidim::Demographics::AdminEngine => "/", :as => :decidim_admin_demographics
        end
      end

      initializer "decidim_admin_demographics.user_menu" do
        Decidim.menu :admin_settings_menu do |menu|
          menu.add_item :demographics,
                        I18n.t("title", scope: "decidim.demographics.admin"),
                        decidim_admin_demographics.settings_path,
                        position: 1.8,
                        icon_name: "team-line",
                        if: allowed_to?(:update, :organization, organization: current_organization),
                        active:
                          is_active_link?(decidim_admin_demographics.settings_path) ||
                          is_active_link?(decidim_admin_demographics.responses_path) ||
                          is_active_link?(decidim_admin_demographics.publish_responses_path) ||
                          is_active_link?(decidim_admin_demographics.edit_questions_questions_path)
        end
      end

      initializer "decidim_admin_demographics.menu" do
        Decidim.menu :admin_demographics_menu do |menu|
          menu.add_item :demographics_settings_edit,
                        I18n.t("settings", scope: "decidim.demographics.admin.demographics_menu"),
                        decidim_admin_demographics.settings_path,
                        icon_name: "settings-4-line"

          menu.add_item :demographics_questions_edit,
                        I18n.t("questions", scope: "decidim.demographics.admin.demographics_menu"),
                        decidim_admin_demographics.edit_questions_questions_path,
                        icon_name: "question-answer-line"

          menu.add_item :demographics_responses_view,
                        I18n.t("responses", scope: "decidim.demographics.admin.demographics_menu"),
                        decidim_admin_demographics.responses_path,
                        icon_name: "draft-line",
                        active: is_active_link?(decidim_admin_demographics.responses_path) ||
                                is_active_link?(decidim_admin_demographics.publish_responses_path)
        end
      end

      def load_seed
        nil
      end
    end
  end
end
