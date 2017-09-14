# frozen_string_literal: true

module Decidim
  module Results
    # The data store for a Result in the Decidim::Results component. It stores a
    # title, description and any other useful information to render a custom result.
    class Result < Results::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasFeature
      include Decidim::HasScope
      include Decidim::HasCategory
      include Decidim::HasReference
      include Decidim::Followable
      include Decidim::Comments::Commentable

      feature_manifest_name "results"

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        feature.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        commentable? && !feature.current_settings.comments_blocked
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Public: Override Commentable concern method `users_to_notify_on_comment_created`
      def users_to_notify_on_comment_created
        (followers | feature.participatory_space.admins).uniq
      end
    end
  end
end
