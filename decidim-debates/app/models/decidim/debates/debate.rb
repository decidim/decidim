# frozen_string_literal: true
module Decidim
  module Debates
    # The data store for a Debate in the Decidim::Debates component. It stores a
    # title, description and any other useful information to render a custom
    # debate.
    class Debate < Debates::ApplicationRecord
      include Decidim::HasFeature
      include Decidim::HasCategory
      include Decidim::Resourceable
      include Decidim::Followable
      include Decidim::Comments::Commentable
      include Decidim::HasScope

      feature_manifest_name "debates"

      has_many :comments, as: :decidim_commentable, class_name: "Decidim::Comments::Comment"

      validates :title, presence: true

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

      # Public: Identifies the commentable type in the API.
      def commentable_type
        self.class.name
      end

      # Public: Overrides the `notifiable?` Notifiable concern method.
      def notifiable?(_context)
        false
      end

      # Public: Overrides the `users_to_notify` Notifiable concern method.
      def users_to_notify
        []
      end
    end
  end
end
