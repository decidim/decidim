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
        return unless render?

        render
      end

      def render?
        options[:render_blank] || has_results?
      end

      def has_results?
        results_count&.positive? || progress.present?
      end

      private

      def scope
        current_scope.presence
      end

      def url
        options[:url]
      end

      def title
        if model.is_a? Decidim::Category
          translated_attribute(model.name)
        else
          options[:title]
        end
      end

      def results_count
        @results_count ||= if model.is_a? Decidim::Category
                             count_calculator(scope, model.id)
                           else
                             options[:count]
                           end
      end

      def progress
        if model.is_a? Decidim::Category
          progress_calculator(scope, model.id).presence
        elsif model.respond_to?(:progress)
          model.progress
        else
          options[:progress] || progress_calculator(scope, nil).presence
        end
      end

      def extra_classes
        options[:extra_classes]
      end

      def count
        return unless results_count&.positive? && render_count

        display_count(results_count)
      end

      def render_count
        return true unless options.has_key?(:render_count)

        options[:render_count]
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
