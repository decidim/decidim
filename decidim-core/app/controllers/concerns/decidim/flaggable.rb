# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A controller concern to enable flagging capabilities to its resources. Only
  # affects the UI, so make sure you check the controller resources implement
  # the `Decidim::Reportable` model concern.
  module Flaggable
    extend ActiveSupport::Concern

    included do
      helper_method :flaggable_controller?, :report_form

      def flaggable_controller?
        true
      end

      def report_form
        Decidim::ReportForm.from_params(reason: "spam")
      end
    end
  end
end
