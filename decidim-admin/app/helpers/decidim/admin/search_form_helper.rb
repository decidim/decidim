# frozen_string_literal: true

module Decidim
  module Admin
    # Overrides some methods from Ransack::Helpers::FormHelper to fix the search
    # user interfaces within Decidim.
    module SearchFormHelper
      # Provide the correct builder option for the admin search forms. Otherwise
      # they would be generated using Ransack::Helpers::FormHelper which does
      # not provide all the same features that the Decidim form builders, such
      # as datetime pickers.
      def search_form_for(record, options = {}, &proc)
        options[:builder] ||= SearchFormBuilder

        super(record, options, &proc)
      end
    end
  end
end
