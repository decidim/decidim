# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module ParticipatoryProcesses
    # Decidim's Processes Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryProcesses::Admin

      routes do
        resources :participatory_process_groups
        resources :participatory_processes do
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

            constraints Decidim::CurrentFeature.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_participatory_process_#{manifest.name}"
            end
          end
        end
      end
    end
  end
end
