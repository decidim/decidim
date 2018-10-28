# frozen_string_literal: true

require "searchlight"
require "kaminari"

module Decidim
  module Debates
    # This is the engine that runs on the public interface of `decidim-debates`.
    # It mostly handles rendering the created debate associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Debates

      routes do
        resources :debates, only: [:index, :show, :new, :create]
        root to: "debates#index"
      end

      initializer "decidim_changes" do
        Decidim::SettingsChange.subscribe "debates" do |changes|
          Decidim::Debates::SettingsChangeJob.perform_later(
            changes[:component_id],
            changes[:previous_settings],
            changes[:current_settings]
          )
        end
      end

      initializer "decidim_meetings.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Debates::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Debates::Engine.root}/app/views") # for partials
      end

      initializer "decidim.debates.commented_debates_badge" do
        Decidim::Gamification.register_badge(:commented_debates) do |badge|
          badge.levels = [1, 5, 10, 30, 50]
          badge.reset = lambda do |user|
            debates = Decidim::Comments::Comment.where(
              decidim_author_id: user.id,
              decidim_root_commentable_type: "Decidim::Debates::Debate"\
            )
            debates.pluck(:decidim_root_commentable_id).uniq.count
          end
        end

        Decidim::Comments::CommentCreation.subscribe do |data|
          comment = Decidim::Comments::Comment.find(data[:comment_id])
          next unless comment.decidim_root_commentable_type == "Decidim::Debates::Debate"

          author = comment.author

          comments = Decidim::Comments::Comment.where(
            decidim_root_commentable_id: comment.decidim_root_commentable_id,
            decidim_root_commentable_type: comment.decidim_root_commentable_type,
            author: author
          )

          Decidim::Gamification.increment_score(author, :commented_debates) if comments.count == 1
        end
      end
    end
  end
end
