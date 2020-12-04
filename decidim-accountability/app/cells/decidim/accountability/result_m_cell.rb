# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the Medium (:m) result card
    # for an instance of a Result
    class ResultMCell < Decidim::CardMCell
      include Decidim::SanitizeHelper
      include Decidim::TranslationsHelper
      include ActiveSupport::NumberHelper

      delegate :start_date, :end_date, :progress, to: :model

      private

      def resource_path
        resource_locator(model).path
      end

      def progress_text
        return if progress.blank?

        number_to_percentage(progress, precision: 1, strip_insignificant_zeros: true, locale: I18n.locale, format: "%n%")
      end

      def statuses
        []
      end

      def has_dates?
        start_date.present? && end_date.present?
      end
    end
  end
end
