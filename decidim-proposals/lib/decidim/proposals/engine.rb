# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    # It mostly handles rendering the created page associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Proposals

      routes do
        resources :proposals, except: [:destroy] do
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
          resource :widget, only: :show, path: "embed"
          resources :versions, only: [:show, :index]
        end
        resources :collaborative_drafts, except: [:destroy] do
          member do
            post :request_access, controller: "collaborative_draft_collaborator_requests"
            post :request_accept, controller: "collaborative_draft_collaborator_requests"
            post :request_reject, controller: "collaborative_draft_collaborator_requests"
            post :withdraw
            post :publish
          end
          resources :versions, only: [:show, :index]
        end
        root to: "proposals#index"
      end

      initializer "decidim.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:proposal]
        end
      end

      initializer "decidim_proposals.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          view_context.cell("decidim/proposals/highlighted_proposals", view_context.current_participatory_space)
        end
      end

      initializer "decidim_changes" do
        config.to_prepare do
          Decidim::SettingsChange.subscribe "surveys" do |changes|
            Decidim::Proposals::SettingsChangeJob.perform_later(
              changes[:component_id],
              changes[:previous_settings],
              changes[:current_settings]
            )
          end
        end
      end

      initializer "decidim_proposals.mentions_listener" do
        config.to_prepare do
          Decidim::Comments::CommentCreation.subscribe do |data|
            proposals = data.dig(:metadatas, :proposal).try(:linked_proposals)
            Decidim::Proposals::NotifyProposalsMentionedJob.perform_later(data[:comment_id], proposals) if proposals
          end
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
            proposal.update(state: "accepted", state_published_at: Time.current)
          end
        end
      end

      initializer "decidim_proposals.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Proposals::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Proposals::Engine.root}/app/views") # for proposal partials
      end

      initializer "decidim_proposals.add_badges" do
        Decidim::Gamification.register_badge(:proposals) do |badge|
          badge.levels = [1, 5, 10, 30, 60]

          badge.valid_for = [:user, :user_group]

          badge.reset = lambda { |model|
            case model
            when User
              Decidim::Coauthorship.where(
                coauthorable_type: "Decidim::Proposals::Proposal",
                author: model,
                user_group: nil
              ).count
            when UserGroup
              Decidim::Coauthorship.where(
                coauthorable_type: "Decidim::Proposals::Proposal",
                user_group: model
              ).count
            end
          }
        end

        Decidim::Gamification.register_badge(:accepted_proposals) do |badge|
          badge.levels = [1, 5, 15, 30, 50]

          badge.valid_for = [:user, :user_group]

          badge.reset = lambda { |model|
            proposal_ids = case model
                           when User
                             Decidim::Coauthorship.where(
                               coauthorable_type: "Decidim::Proposals::Proposal",
                               author: model,
                               user_group: nil
                             ).select(:coauthorable_id)
                           when UserGroup
                             Decidim::Coauthorship.where(
                               coauthorable_type: "Decidim::Proposals::Proposal",
                               user_group: model
                             ).select(:coauthorable_id)
                           end

            Decidim::Proposals::Proposal.where(id: proposal_ids).accepted.count
          }
        end

        Decidim::Gamification.register_badge(:proposal_votes) do |badge|
          badge.levels = [5, 15, 50, 100, 500]

          badge.reset = lambda { |user|
            Decidim::Proposals::ProposalVote.where(author: user).select(:decidim_proposal_id).distinct.count
          }
        end
      end

      initializer "decidim_proposals.register_metrics" do
        Decidim.metrics_registry.register(:proposals) do |metric_registry|
          metric_registry.manager_class = "Decidim::Proposals::Metrics::ProposalsMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: true
            settings.attribute :scopes, type: :array, default: %w(home participatory_process)
            settings.attribute :weight, type: :integer, default: 2
            settings.attribute :stat_block, type: :string, default: "medium"
          end
        end

        Decidim.metrics_registry.register(:accepted_proposals) do |metric_registry|
          metric_registry.manager_class = "Decidim::Proposals::Metrics::AcceptedProposalsMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(home participatory_process)
            settings.attribute :weight, type: :integer, default: 3
            settings.attribute :stat_block, type: :string, default: "small"
          end
        end

        Decidim.metrics_registry.register(:votes) do |metric_registry|
          metric_registry.manager_class = "Decidim::Proposals::Metrics::VotesMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: true
            settings.attribute :scopes, type: :array, default: %w(home participatory_process)
            settings.attribute :weight, type: :integer, default: 3
            settings.attribute :stat_block, type: :string, default: "medium"
          end
        end

        Decidim.metrics_registry.register(:endorsements) do |metric_registry|
          metric_registry.manager_class = "Decidim::Proposals::Metrics::EndorsementsMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(participatory_process)
            settings.attribute :weight, type: :integer, default: 4
            settings.attribute :stat_block, type: :string, default: "medium"
          end
        end

        Decidim.metrics_operation.register(:participants, :proposals) do |metric_operation|
          metric_operation.manager_class = "Decidim::Proposals::Metrics::ProposalParticipantsMetricMeasure"
        end
        Decidim.metrics_operation.register(:followers, :proposals) do |metric_operation|
          metric_operation.manager_class = "Decidim::Proposals::Metrics::ProposalFollowersMetricMeasure"
        end
      end

      initializer "decidim_proposals.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_proposals.authorization_transfer" do
        Decidim::AuthorizationTransfer.register(:proposals) do |transfer|
          transfer.move_records(Decidim::Proposals::ProposalVote, :decidim_author_id)
        end
      end
    end
  end
end
