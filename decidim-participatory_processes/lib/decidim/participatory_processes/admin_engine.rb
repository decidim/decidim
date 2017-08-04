# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module ParticipatoryProcesses
    # Decidim's Processes Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryProcesses::Admin

      paths["db/migrate"] = nil

      routes do
        resources :participatory_process_groups
        resources :participatory_processes, except: :show do
          resource :publish, controller: "participatory_process_publications", only: [:create, :destroy]
          resources :copies, controller: "participatory_process_copies", only: [:new, :create]

          resources :steps, controller: "participatory_process_steps" do
            resource :activate, controller: "participatory_process_step_activations", only: [:create, :destroy]
            collection do
              post :ordering, to: "participatory_process_step_ordering#create"
            end
          end
          resources :user_roles, controller: "participatory_process_user_roles" do
            member do
              post :resend_invitation, to: "participatory_process_user_roles#resend_invitation"
            end
          end
          resources :attachments, controller: "participatory_process_attachments"
        end

        scope "/participatory_processes/:participatory_process_id" do
          resources :categories

          resources :features do
            resource :permissions, controller: "feature_permissions"
            member do
              put :publish
              put :unpublish
            end
            resources :exports, only: :create
          end

          resources :moderations do
            member do
              put :unreport
              put :hide
            end
          end
        end

        scope "/participatory_processes/:participatory_process_id/features/:feature_id/manage" do
          Decidim.feature_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentFeature.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_participatory_process_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_participatory_processes.assets" do |app|
        app.config.assets.precompile += %w(decidim_participatory_processes_manifest.js)
      end

      initializer "decidim_participatory_processes.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            "Decidim::ParticipatoryProcesses::Abilities::Admin::AdminAbility"
          ]
        end
      end

      initializer "decidim_participatory_processes.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.participatory_processes", scope: "decidim.admin"),
                    decidim_admin_participatory_processes.participatory_processes_path,
                    icon_name: "target",
                    position: 2,
                    active: :inclusive,
                    if: can?(:manage, Decidim::ParticipatoryProcess)

          menu.item I18n.t("menu.participatory_process_groups", scope: "decidim.admin"),
                    decidim_admin_participatory_processes.participatory_process_groups_path,
                    icon_name: "layers",
                    position: 3,
                    active: :inclusive,
                    if: can?(:read, Decidim::ParticipatoryProcessGroup)
        end
      end
    end
  end
end
