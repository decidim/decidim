# frozen_string_literal: true
module Decidim
  module Pages
    # The data store for a Page in the Decidim::Pages component. It stores a
    # title, description and any other useful information to render a custom page.
    class Page < Pages::ApplicationRecord
      include Decidim::Comments::Commentable

      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: Decidim::Feature
      has_one :organization, through: :feature

      validates :feature, presence: true
      validate :feature_manifest_matches

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        feature.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
         commentable? && !feature.active_step_settings.comments_blocked
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      private

      def feature_manifest_matches
        return unless feature
        errors.add(:feature, :invalid) unless feature.manifest_name == "pages"
      end
    end
  end
end
