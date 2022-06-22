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
          resources :versions, only: [:show, :index]
          resource :widget, only: :show, path: "embed"
        end
        root to: "debates#index"
      end

      initializer "decidim_changes" do
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

      initializer "decidim_meetings.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Debates::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Debates::Engine.root}/app/views") # for partials
      end

      initializer "decidim.debates.commented_debates_badge" do
        Decidim::Gamification.register_badge(:commented_debates) do |badge|
          badge.levels = [1, 5, 10, 30, 50]

          badge.valid_for = [:user, :user_group]

          badge.reset = lambda do |user|
            debates = Decidim::Comments::Comment.where(
              author: user,
              decidim_root_commentable_type: "Decidim::Debates::Debate"\
            )
            debates.pluck(:decidim_root_commentable_id).uniq.count
          end
        end

        config.to_prepare do
          Decidim::Comments::CommentCreation.subscribe do |data|
            comment = Decidim::Comments::Comment.find(data[:comment_id])
            next unless comment.decidim_root_commentable_type == "Decidim::Debates::Debate"

            if comment.user_group.present?
              comments = Decidim::Comments::Comment.where(
                decidim_root_commentable_id: comment.decidim_root_commentable_id,
                decidim_root_commentable_type: comment.decidim_root_commentable_type,
                user_group: comment.user_group
              )

              Decidim::Gamification.increment_score(comment.user_group, :commented_debates) if comments.count == 1
            elsif comment.author.present?
              comments = Decidim::Comments::Comment.where(
                decidim_root_commentable_id: comment.decidim_root_commentable_id,
                decidim_root_commentable_type: comment.decidim_root_commentable_type,
                author: comment.author
              )

              Decidim::Gamification.increment_score(comment.author, :commented_debates) if comments.count == 1
            end
          end
        end
      end

      initializer "decidim_debates.register_metrics" do
        Decidim.metrics_registry.register(:debates) do |metric_registry|
          metric_registry.manager_class = "Decidim::Debates::Metrics::DebatesMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(participatory_process)
            settings.attribute :weight, type: :integer, default: 3
            settings.attribute :stat_block, type: :string, default: "small"
          end
        end

        Decidim.metrics_operation.register(:participants, :debates) do |metric_operation|
          metric_operation.manager_class = "Decidim::Debates::Metrics::DebateParticipantsMetricMeasure"
        end

        Decidim.metrics_operation.register(:followers, :debates) do |metric_operation|
          metric_operation.manager_class = "Decidim::Debates::Metrics::DebateFollowersMetricMeasure"
        end
      end

      initializer "decidim_debates.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_debates.authorization_transfer" do
        Decidim::AuthorizationTransfer.subscribe do |authorization, target_user|
          # rubocop:disable Rails/SkipsModelValidations
          Decidim::Debates::Debate.where(author: authorization.user).update_all(
            decidim_author_id: target_user.id
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
