# frozen_string_literal: true

module Decidim
  module Surveys
    # The data store for a Survey in the Decidim::Surveys component.
    class Survey < Surveys::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Forms::HasQuestionnaire
      include Decidim::HasComponent
      include Decidim::TranslatableResource

      component_manifest_name "surveys"

      translatable_fields :title, :description, :tos

      validates :questionnaire, presence: true

      def clean_after_publish?
        component.settings.clean_after_publish?
      end
    end
  end
end
