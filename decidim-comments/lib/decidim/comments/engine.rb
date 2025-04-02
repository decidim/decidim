# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

require "decidim/comments/query_extensions"
require "decidim/comments/mutation_extensions"

module Decidim
  module Comments
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Comments

      routes do
        resources :comments, except: [:new, :edit] do
          resources :votes, only: [:create]
        end
      end

      initializer "decidim_comments.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Comments::Engine, at: "/", as: "decidim_comments"
        end
      end

      initializer "decidim_comments.query_extensions" do
        Decidim::Api::QueryType.include QueryExtensions
      end

      initializer "decidim_comments.mutation_extensions" do
        Decidim::Api::MutationType.include MutationExtensions
      end

      initializer "decidim_comments.stats" do
        Decidim.stats.register :comments_count, priority: StatsRegistry::MEDIUM_PRIORITY do |organization|
          Decidim.component_manifests.sum do |component|
            component.stats.filter(tag: :comments).with_context(organization.published_components).map { |_name, value| value }.sum
          end
        end
      end

      initializer "decidim_comments.register_icons" do
        common_parameters = { category: "action", engine: :comments }

        Decidim.icons.register(name: "Decidim::Comments::Comment", icon: "chat-1-line", description: "Comment", category: "activity", engine: :comments)
        Decidim.icons.register(name: "comments_count", icon: "wechat-line", description: "Comments Count", category: "activity", engine: :comments)
        Decidim.icons.register(name: "star-s-line", icon: "star-s-line", description: "Most upvoted comment", category: "activity", engine: :comments)

        Decidim.icons.register(name: "thumb-up-line", icon: "thumb-up-line", description: "Upvote comment button", **common_parameters)
        Decidim.icons.register(name: "thumb-up-fill", icon: "thumb-up-fill", description: "User upvoted comment", **common_parameters)
        Decidim.icons.register(name: "thumb-down-line", icon: "thumb-down-line", description: "Downvote comment button", **common_parameters)
        Decidim.icons.register(name: "thumb-down-fill", icon: "thumb-down-fill", description: "User downvoted comment", **common_parameters)
        Decidim.icons.register(name: "edit-line", icon: "edit-line", description: "Edit comment button", **common_parameters)
      end

      initializer "decidim_comments.register_resources" do
        Decidim.register_resource(:comment) do |resource|
          resource.model_class_name = "Decidim::Comments::Comment"
          resource.card = "decidim/comments/comment_card"
          resource.searchable = true
        end
      end

      initializer "decidim_comments.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Comments::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Comments::Engine.root}/app/views") # for partials
      end

      initializer "decidim_comments.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_comments.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:comments) do |transfer|
            transfer.move_records(Decidim::Comments::Comment, :decidim_author_id)
            transfer.move_records(Decidim::Comments::CommentVote, :decidim_author_id)
          end
        end
      end

      initializer "decidim_comments.moderation_content" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.admin.block_user:after") do |_event_name, data|
            Decidim::Comments::HideAllCreatedByAuthorJob.perform_later(**data)
          end
        end
      end
    end
  end
end
