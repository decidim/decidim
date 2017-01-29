# frozen_string_literal: true
module Decidim
  module Pages
    # The data store for a Page in the Decidim::Pages component. It stores a
    # title, description and any other useful information to render a custom page.
    class Page < Pages::ApplicationRecord
      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: Decidim::Feature
      has_one :organization, through: :feature

      validates :title, :feature, presence: true
      validate :feature_manifest_matches

      private

      def feature_manifest_matches
        return unless feature
        errors.add(:feature, :invalid) unless feature.manifest_name == "pages"
      end
    end
  end
end
