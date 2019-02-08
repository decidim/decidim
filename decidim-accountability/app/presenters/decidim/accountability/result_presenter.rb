# frozen_string_literal: true

module Decidim
  module Accountability
    #
    # Decorator for results
    #
    class ResultPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::TranslationsHelper

      def result_path
        result = __getobj__
        Decidim::ResourceLocatorPresenter.new(result).path
      end

      def display_mention
        link_to translated_attribute(title), result_path
      end
    end
  end
end
