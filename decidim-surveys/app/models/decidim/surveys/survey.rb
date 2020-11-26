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
      validates :starts_at, presence: { if: ->(object) { object.ends_at.present? } }

      def clean_after_publish?
        component.settings.clean_after_publish?
      end

      def open?
        return true if starts_at.blank?
        return true if ends_at.blank? && starts_at.past?

        Time.zone.now.between?(starts_at, ends_at)
      end
    end
  end
end
