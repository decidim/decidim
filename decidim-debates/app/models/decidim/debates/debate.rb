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

      validates :title, presence: true

      # Public: Calculates whether the current debate is an AMA-styled one or not.
      #
      # Returns a Boolean.
      def ama?
        start_time.present? && end_time.present?
      end

      # Public: Checks whether the debate is an AMA-styled one and is open.
      #
      # Returns a boolean.
      def open_ama?
        ama? && Time.current.between?(start_time, end_time)
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        feature.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        return false unless open_ama?
        commentable? && !comments_blocked?
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

      private

      def comments_blocked?
        feature.current_settings.comments_blocked
      end
    end
  end
end
