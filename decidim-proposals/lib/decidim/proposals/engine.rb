# frozen_string_literal: true

require "kaminari"
require "social-share-button"
require "ransack"
require "cells/rails"
require "cells-erb"
require "cell/partial"

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
            get :complete
            get :edit_draft
            patch :update_draft
            get :preview
            post :publish
            delete :destroy_draft
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

      initializer "decidim.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:proposal]
        end
      end

      initializer "decidim_proposals.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          proposals = Decidim::Proposals::Proposal.published.not_hidden.except_withdrawn
                                                  .where(component: published_components)
                                                  .order_randomly(rand * 2 - 1)
                                                  .limit(Decidim::Proposals.config.participatory_space_highlighted_proposals_limit)

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
            proposals = Decidim::Proposals::Proposal.published.not_hidden.except_withdrawn
                                                    .where(component: published_components)
                                                    .order_randomly(rand * 2 - 1)
                                                    .limit(Decidim::Proposals.config.process_group_highlighted_proposals_limit)

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

      initializer "decidim_proposals.mentions_listener" do
        Decidim::Comments::CommentCreation.subscribe do |data|
          metadata = data[:metadatas][:proposals]
          Decidim::Proposals::NotifyProposalsMentionedJob.perform_later(data[:comment_id], metadata)
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

      initializer "decidim_proposals.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Proposals::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Proposals::Engine.root}/app/views") # for proposal partials
      end

      initializer "decidim_proposals.query_extensions" do
        Decidim::Api::QueryType.define do
          QueryExtensions.define(self)
        end
      end

      initializer "decidim_proposals.register_metrics" do
        Decidim.metrics_registry.register(
          :proposals,
          "Decidim::Proposals::Metrics::ProposalsMetricManage",
          Decidim::MetricRegistry::HIGHLIGHTED
        )

        Decidim.metrics_registry.register(
          :accepted_proposals,
          "Decidim::Proposals::Metrics::AcceptedProposalsMetricManage",
          Decidim::MetricRegistry::NOT_HIGHLIGHTED
        )

        Decidim.metrics_registry.register(
          :votes,
          "Decidim::Proposals::Metrics::VotesMetricManage",
          Decidim::MetricRegistry::NOT_HIGHLIGHTED
        )
      end
    end
  end
end
