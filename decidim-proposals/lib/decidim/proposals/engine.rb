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
            get :edit_draft
            patch :update_draft
            get :preview
            post :publish
            delete :destroy_draft
            put :withdraw
          end
          resource :proposal_vote, only: [:create, :destroy]
          resources :versions, only: [:show]
          resources :invite_coauthors, only: [:index, :create, :update, :destroy] do
            collection do
              delete :cancel
            end
          end
        end
        resources :collaborative_drafts, except: [:destroy] do
          member do
            post :request_access, controller: "collaborative_draft_collaborator_requests"
            post :request_accept, controller: "collaborative_draft_collaborator_requests"
            post :request_reject, controller: "collaborative_draft_collaborator_requests"
            post :withdraw
            post :publish
          end
          resources :versions, only: [:show]
        end
        scope "/proposals" do
          root to: "proposals#index"
        end
        get "/", to: redirect("proposals", status: 301)
      end

      initializer "decidim_proposals.register_icons" do
        Decidim.icons.register(name: "Decidim::Proposals::CollaborativeDraft", icon: "draft-line", category: "activity",
                               description: "Collaborative draft", engine: :proposals)
        Decidim.icons.register(name: "Decidim::Proposals::Proposal", icon: "chat-new-line", category: "activity",
                               description: "Proposal", engine: :proposals)
        Decidim.icons.register(name: "participatory_texts_item", icon: "bookmark-line", description: "Index item", category: "participatory_texts",
                               engine: :proposals)

        Decidim.icons.register(name: "scan-line", icon: "scan-line", category: "system", description: "", engine: :proposals)
        Decidim.icons.register(name: "edit-2-line", icon: "edit-2-line",
                               category: "action", description: "Edit icon for Collaborative Drafts", engine: :proposals)

        Decidim.icons.register(name: "bookmark-line", icon: "bookmark-line", category: "system", description: "", engine: :proposals)
        Decidim.icons.register(name: "arrow-right-s-fill", icon: "arrow-right-s-fill", category: "system", description: "", engine: :proposals)
        Decidim.icons.register(name: "bar-chart-2-line", icon: "bar-chart-2-line", category: "system", description: "", engine: :proposals)
        Decidim.icons.register(name: "scales-line", icon: "scales-line", category: "system", description: "", engine: :proposals)
        Decidim.icons.register(name: "layout-grid-fill", icon: "layout-grid-fill", category: "system", description: "", engine: :proposals)
      end

      initializer "decidim_proposals.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:proposal]
        end
      end

      initializer "decidim_proposals.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          view_context.cell("decidim/proposals/highlighted_proposals", view_context.current_participatory_space)
        end
      end

      initializer "decidim_proposals.settings_changes" do
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

      initializer "decidim_proposals.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Proposals::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Proposals::Engine.root}/app/views") # for proposal partials
      end

      initializer "decidim_proposals.remove_space_admins" do
        ActiveSupport::Notifications.subscribe("decidim.admin.participatory_space.destroy_admin:after") do |_event_name, data|
          Decidim::Proposals::EvaluationAssignment.where(evaluator_role_type: data.fetch(:class_name), evaluator_role_id: data.fetch(:role)).destroy_all
        end
      end

      initializer "decidim_proposals.add_badges" do
        Decidim::Gamification.register_badge(:proposals) do |badge|
          badge.levels = [1, 5, 10, 30, 60]

          badge.valid_for = [:user]

          badge.reset = lambda { |model|
            Decidim::Coauthorship.where(
              coauthorable_type: "Decidim::Proposals::Proposal",
              author: model
            ).count
          }
        end

        Decidim::Gamification.register_badge(:accepted_proposals) do |badge|
          badge.levels = [1, 5, 15, 30, 50]

          badge.valid_for = [:user]

          badge.reset = lambda { |model|
            proposal_ids = Decidim::Coauthorship.where(
              coauthorable_type: "Decidim::Proposals::Proposal",
              author: model
            ).select(:coauthorable_id)

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

      initializer "decidim_proposals.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_proposals.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:proposals) do |transfer|
            transfer.move_records(Decidim::Proposals::ProposalVote, :decidim_author_id)
          end
        end
      end

      initializer "decidim_proposals.moderation_content" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.admin.block_user:after") do |_event_name, data|
            Decidim::Proposals::HideAllCreatedByAuthorJob.perform_later(**data)
          end
        end
      end
    end
  end
end
