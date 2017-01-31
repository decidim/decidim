# frozen_string_literal: true
require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to have a feature.
  module HasFeature
    extend ActiveSupport::Concern

    included do
      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: "Decidim::Feature"
      has_one :organization, through: :feature
    end

    class_methods do
      def feature_manifest_name(manifest_name)
        validates :feature, feature: { manifest: manifest_name || name.demodulize.pluralize.downcase }
      end
    end
  end
end
