# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the status of a category
    class StatusCell < Decidim::ViewModel
      include ApplicationHelper
      include BreadcrumbHelper
      include Decidim::TranslationsHelper
      include ActiveSupport::NumberHelper

      delegate :current_component, :component_settings, to: :controller

      def show
        return if results_count.zero?

        render
      end

      private

      def url
        options[:url]
      end

      def title
        translated_attribute(model.name)
      end

      def results_count
        @results_count ||= count_calculator(current_scope, model.id)
      end

      def progress
        progress_calculator(current_scope, model.id).presence
      end

      def extra_classes
        options[:extra_classes]
      end

      def count
        return unless results_count&.positive?

        display_count(results_count)
      end

      def count_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, scope_id, category_id).count
      end

      def decidim
        Decidim::Accountability::Engine.routes.url_helpers
      end
    end
  end
end
