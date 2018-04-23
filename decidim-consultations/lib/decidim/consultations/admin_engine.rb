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

      routes do
        resources :consultations, param: :slug, except: :show do
          resource :publish, controller: "consultation_publications", only: [:create, :destroy]
          resource :publish_results, controller: "consultation_results_publications", only: [:create, :destroy]
          resources :questions, param: :slug, except: :show, shallow: true do
            resource :publish, controller: "question_publications", only: [:create, :destroy]
          end
        end

        scope "/questions/:question_slug" do
          resources :categories
          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
            end
            resources :exports, only: :create
          end

          resources :question_attachments
          resources :responses, except: :show
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

      initializer "decidim_consultations.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += %w(
            Decidim::Consultations::Abilities::Admin::ConsultationAdminAbility
            Decidim::Consultations::Abilities::Admin::QuestionAdminAbility
            Decidim::Consultations::Abilities::Admin::ResponseAdminAbility
          )
        end
      end

      initializer "decidim_consultations.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.consultations", scope: "decidim.admin"),
                    decidim_admin_consultations.consultations_path,
                    icon_name: "comment-square",
                    position: 3.8,
                    active: :inclusive,
                    if: can?(:index, Decidim::Consultation) &&
                        Decidim.find_participatory_space_manifest(:consultations).space_for(current_organization).active?
        end
      end
    end
  end
end
