# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This module, when injected into a controller, ensures there's a
  # helper with the terms and conditions static page
  module NeedsTermsAndConditionsPage
    extend ActiveSupport::Concern

    included do
      helper_method :terms_and_conditions_page

      private

      def terms_and_conditions_page
        @terms_and_conditions_page ||= Decidim::StaticPage.find_by_slug('terms-and-conditions')
      end
    end
  end
end
