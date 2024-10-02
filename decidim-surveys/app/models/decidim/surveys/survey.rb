# frozen_string_literal: true

module Decidim
  module Surveys
    # The data store for a Survey in the Decidim::Surveys component.
    class Survey < Surveys::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Forms::HasQuestionnaire
      include Decidim::HasComponent
      include Decidim::FilterableResource

      component_manifest_name "surveys"

      delegate :title, to: :questionnaire
      delegate :description, to: :questionnaire
      delegate :tos, to: :questionnaire

      validates :questionnaire, presence: true

      scope :open, -> { where("ends_at IS NULL OR ends_at > ?", Time.zone.now) }
      scope :closed, -> { where(ends_at: ..Time.zone.now) }

      scope_search_multi :with_any_state, [:open, :closed]

      def open?
        return true if starts_at.blank? && ends_at.blank?
        return true if ends_at.blank? && starts_at.past?
        return true if starts_at.blank? && ends_at.future?

        return Time.zone.now.between?(starts_at, ends_at) if starts_at.present? && ends_at.present?

        false
      end

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_state]
      end

      def self.ransackable_attributes(_auth_object = nil)
        %w(ends_at starts_at)
      end
    end
  end
end
