# frozen_string_literal: true
module Decidim
  module Budgets
    # The data store for a Project in the Decidim::Budgets component. It stores a
    # title, description and any other useful information to render a custom project.
    class Project < Budgets::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasFeature
      include Decidim::HasScope
      include Decidim::HasCategory
      include Decidim::HasAttachments
      include Decidim::Comments::Commentable

      feature_manifest_name "budgets"

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        feature.active_step_settings.comments_enabled?
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end
    end
  end
end
