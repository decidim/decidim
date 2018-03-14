# frozen_string_literal: true

require "kaminari"
require "social-share-button"
require "ransack"

module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    # It mostly handles rendering the created page associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Proposals

      routes do
        resources :proposals, except: [:destroy] do
          resource :proposal_endorsement, only: [:create, :destroy] do
            get :identities, on: :collection
          end
          member do
            get :compare
            get :edit_draft
            patch :update_draft
            get :preview
            post :publish
            put :withdraw
          end
          resource :proposal_vote, only: [:create, :destroy]
          resource :proposal_widget, only: :show, path: "embed"
        end
        root to: "proposals#index"
      end

      initializer "decidim_proposals.assets" do |app|
        app.config.assets.precompile += %w(decidim_proposals_manifest.js
                                           decidim_proposals_manifest.css
                                           decidim/proposals/identity_selector_dialog.js)
      end

      initializer "decidim_proposals.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += ["Decidim::Proposals::Abilities::CurrentUserAbility"]
        end
      end

      initializer "decidim_proposals.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          proposals = Decidim::Proposals::Proposal.where(component: published_components).order_randomly(rand * 2 - 1).limit(4)

          next unless proposals.any?

          view_context.extend Decidim::Proposals::ApplicationHelper
          view_context.render(
            partial: "decidim/participatory_spaces/highlighted_proposals",
            locals: {
              proposals: proposals
            }
          )
        end

        if defined? Decidim::ParticipatoryProcesses
          Decidim::ParticipatoryProcesses.view_hooks.register(:process_group_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
            published_components = Decidim::Component.where(participatory_space: view_context.participatory_processes).published
            proposals = Decidim::Proposals::Proposal.where(component: published_components).order_randomly(rand * 2 - 1).limit(3)

            next unless proposals.any?

            view_context.extend Decidim::ResourceReferenceHelper
            view_context.extend Decidim::Proposals::ApplicationHelper
            view_context.render(
              partial: "decidim/participatory_processes/participatory_process_groups/highlighted_proposals",
              locals: {
                proposals: proposals
              }
            )
          end
        end
      end

      initializer "decidim_changes" do
        Decidim::SettingsChange.subscribe "surveys" do |changes|
          Decidim::Proposals::SettingsChangeJob.perform_later(
            changes[:component_id],
            changes[:previous_settings],
            changes[:current_settings]
          )
        end
      end

      # Subscribes to ActiveSupport::Notifications that may affect a Proposal.
      initializer "decidim_proposals.subscribe_to_events" do
        # when a proposal is linked from a result
        event_name = "decidim.resourceable.included_proposals.created"
        ActiveSupport::Notifications.subscribe event_name do |_name, _started, _finished, _unique_id, data|
          payload = data[:this]
          if payload[:from_type] == Decidim::Accountability::Result.name && payload[:to_type] == Proposal.name
            proposal = Proposal.find(payload[:to_id])
            proposal.update(state: "accepted")
          end
        end
      end
    end
  end
end
