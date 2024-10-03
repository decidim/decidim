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

      scope :open, lambda {
        where(allow_answers: true)
          .where(starts_at: nil, ends_at: nil).or(
            where("starts_at <= ? AND (ends_at IS NULL OR ends_at > ?)", Time.current, Time.current)
          ).or(
            where("ends_at > ? AND (starts_at IS NULL OR starts_at <= ?)", Time.current, Time.current)
          )
      }
      scope :closed, lambda {
        where(allow_answers: false).or(
          where("starts_at > ?", Time.current).or(
            where(ends_at: ...Time.current)
          )
        )
      }

      scope_search_multi :with_any_state, [:open, :closed]

      def open?
        return false if allow_answers.blank?
        return true if time_indefinite?
        return true if started_but_no_end?
        return true if no_start_but_ends_later?

        return within_time_range? if time_range_defined?

        false
      end

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_state]
      end

      def self.ransackable_attributes(_auth_object = nil)
        %w(ends_at starts_at allow_answers)
      end

      private

      def time_indefinite?
        starts_at.blank? && ends_at.blank?
      end

      def started_but_no_end?
        ends_at.blank? && starts_at.past?
      end

      def no_start_but_ends_later?
        starts_at.blank? && ends_at.future?
      end

      def time_range_defined?
        starts_at.present? && ends_at.present?
      end

      def within_time_range?
        Time.zone.now.between?(starts_at, ends_at)
      end
    end
  end
end
