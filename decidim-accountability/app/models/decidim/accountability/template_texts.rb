# frozen_string_literal: true

module Decidim
  module Accountability
    # The data store for a Result in the Decidim::Accountability component. It stores a
    # title, description and any other useful information to render a custom result.
    class TemplateTexts < Accountability::ApplicationRecord
      include Decidim::HasFeature

      feature_manifest_name "accountability"

      def self.for(current_feature)
        self.where(feature: current_feature).first || self.create!(feature: current_feature)
      end
    end
  end
end
