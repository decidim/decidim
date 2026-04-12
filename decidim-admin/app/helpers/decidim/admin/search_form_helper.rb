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
      def search_form_for(record, options = {}, &)
        options[:builder] ||= SearchFormBuilder
        options[:url] = url_for(params.to_unsafe_h.except("locale", :locale).merge(locale: nil)) if options[:url].blank?

        super
      end

      def sort_link(search_object, attribute, *args, &)
        options = args.extract_options!
        options = options.merge(params: sort_link_params)
        args << options

        super
      end

      private

      def sort_link_params
        request_params = params.to_unsafe_h.except("locale", :locale).merge(locale: nil)
        request_params["q"] = request_params["q"].except("s", :s) if request_params["q"].is_a?(Hash)
        request_params
      end
    end
  end
end
