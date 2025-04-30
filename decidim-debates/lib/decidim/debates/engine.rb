# frozen_string_literal: true

module Decidim
  module Debates
    # This is the engine that runs on the public interface of `decidim-debates`.
    # It mostly handles rendering the created debate associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Debates

      routes do
        resources :debates, except: [:destroy] do
          member do
            post :close
          end
          resources :versions, only: [:show]
        end
        scope "/debates" do
          root to: "debates#index"
        end
        get "/", to: redirect("debates", status: 301)
      end

      initializer "decidim_debates.register_icons" do
        Decidim.icons.register(name: "Decidim::Debates::Debate", icon: "discuss-line", description: "Debate", category: "activity", engine: :debates)
      end

      initializer "decidim_debates.settings_changes" do
        config.to_prepare do
          Decidim::SettingsChange.subscribe "debates" do |changes|
            Decidim::Debates::SettingsChangeJob.perform_later(
              changes[:component_id],
              changes[:previous_settings],
              changes[:current_settings]
            )
          end
        end
      end

      initializer "decidim_debates.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Debates::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Debates::Engine.root}/app/views") # for partials
      end

      initializer "decidim_debates.commented_debates_badge" do
        Decidim::Gamification.register_badge(:commented_debates) do |badge|
          badge.levels = [1, 5, 10, 30, 50]

          badge.valid_for = [:user]

          badge.reset = lambda do |user|
            debates = Decidim::Comments::Comment.where(
              author: user,
              decidim_root_commentable_type: "Decidim::Debates::Debate"
            )
            debates.pluck(:decidim_root_commentable_id).uniq.count
          end
        end

        config.to_prepare do
          Decidim::Comments::CommentCreation.subscribe do |data|
            comment = Decidim::Comments::Comment.find(data[:comment_id])
            next unless comment.decidim_root_commentable_type == "Decidim::Debates::Debate"

            comments = Decidim::Comments::Comment.where(
              decidim_root_commentable_id: comment.decidim_root_commentable_id,
              decidim_root_commentable_type: comment.decidim_root_commentable_type,
              author: comment.author
            )

            Decidim::Gamification.increment_score(comment.author, :commented_debates) if comments.count == 1
          end
        end
      end

      initializer "decidim_debates.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_debates.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:debates) do |transfer|
            transfer.move_records(Decidim::Debates::Debate, :decidim_author_id)
          end
        end
      end

      initializer "decidim_debates.moderation_content" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.admin.block_user:after") do |_event_name, data|
            Decidim::Debates::HideAllCreatedByAuthorJob.perform_later(**data)
          end
        end
      end
    end
  end
end
