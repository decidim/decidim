# frozen_string_literal: true
module Decidim
  module Surveys
    # The data store for a Survey in the Decidim::Surveys component.
    class Survey < Surveys::ApplicationRecord
      include Decidim::HasFeature

      feature_manifest_name "surveys"
    end
  end
end
