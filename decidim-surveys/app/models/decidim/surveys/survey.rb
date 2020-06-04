# frozen_string_literal: true

module Decidim
  module Surveys
    # The data store for a Survey in the Decidim::Surveys component.
    class Survey < Surveys::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Forms::HasQuestionnaire
      include Decidim::HasComponent

      component_manifest_name "surveys"

      validates :questionnaire, presence: true
    end
  end
end
