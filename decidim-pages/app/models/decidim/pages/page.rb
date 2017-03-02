# frozen_string_literal: true
module Decidim
  module Pages
    # The data store for a Page in the Decidim::Pages component. It stores a
    # title, description and any other useful information to render a custom page.
    class Page < Pages::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasFeature
      include Decidim::Comments::Commentable

      feature_manifest_name "pages"

      # Public: Pages doesn't have title so we assign the feature one to it.
      def title
        feature.name
      end

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
    end
  end
end
