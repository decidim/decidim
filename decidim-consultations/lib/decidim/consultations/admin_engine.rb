# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

module Decidim
  module Consultations
    # Decidim's Consultations Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Consultations::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :consultations, param: :slug, except: [:show, :destroy] do
          get :results, on: :member
          resource :publish, controller: "consultation_publications", only: [:create, :destroy]
          resource :publish_results, controller: "consultation_results_publications", only: [:create, :destroy]
          resources :questions, param: :slug, except: :show, shallow: true do
            resource :publish, controller: "question_publications", only: [:create, :destroy]
            resource :permissions, controller: "question_permissions"
            resource :configuration, controller: "question_configuration", only: [:edit, :update]
          end
        end

        scope "/questions/:question_slug" do
          resources :categories
          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
              get :share
            end
            resources :exports, only: :create
          end

          resources :question_attachments
          resources :responses, except: :show
          resources :response_groups, except: :show
        end

        scope "/questions/:question_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_question_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_consultations.admin_consultation_menu" do
        Decidim.menu :admin_consultation_menu do |menu|
          menu.item I18n.t("info", scope: "decidim.admin.menu.consultations_submenu"),
                    decidim_admin_consultations.edit_consultation_path(current_consultation),
                    position: 1.0,
                    active: is_active_link?(decidim_admin_consultations.edit_consultation_path(current_consultation)),
                    if: allowed_to?(:update, :consultation, consultation: current_consultation)
          menu.item I18n.t("questions", scope: "decidim.admin.menu.consultations_submenu"),
                    decidim_admin_consultations.consultation_questions_path(current_consultation),
                    position: 1.1,
                    active: is_active_link?(decidim_admin_consultations.consultation_questions_path(current_consultation)),
                    if: allowed_to?(:read, :question)
          menu.item I18n.t("results", scope: "decidim.admin.menu.consultations_submenu"),
                    decidim_admin_consultations.results_consultation_path(current_consultation),
                    position: 1.0,
                    active: is_active_link?(decidim_admin_consultations.results_consultation_path(current_consultation)),
                    if: allowed_to?(:read, :question)
        end
      end
      initializer "decidim_consultations.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.consultations", scope: "decidim.admin"),
                    decidim_admin_consultations.consultations_path,
                    icon_name: "comment-square",
                    position: 2.65,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :consultations)
        end
      end
      initializer "decidim_consultations.action_controller" do |_app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::Consultations::Admin::ConsultationMenuHelper if respond_to?(:helper)
        end
      end
    end
  end
end
