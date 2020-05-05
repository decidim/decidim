# frozen_string_literal: true

module Decidim
  module Surveys
    # The data store for a Survey in the Decidim::Surveys component.
    class Survey < Surveys::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Forms::HasMultipleQuestionnaires
      include Decidim::HasComponent

      component_manifest_name "surveys"

      validates :questionnaires, presence: true
    end
  end
end
