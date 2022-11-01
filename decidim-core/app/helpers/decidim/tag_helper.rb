# frozen_string_literal: true

module Decidim
  module TagHelper
    extend ActiveSupport::Concern

    included do
      # Customized to remove the `autocomplete` attribute from hidden inputs as
      # an accessibility violation. Otherwise exactly the same as original.
      #
      # @see ActionView::Helpers::TagHelper#tag
      # rubocop:disable Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Style/OptionalBooleanParameter
      def tag(name = nil, options = nil, open = false, escape = true)
        if name&.to_sym == :input && options.is_a?(Hash)
          type = options[:type] || options["type"]
          if type&.to_sym == :hidden
            options.delete(:autocomplete)
            options.delete("autocomplete")
          end
        end

        if name.nil?
          tag_builder
        else
          name = ERB::Util.xml_name_escape(name) if escape
          "<#{name}#{tag_builder.tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
        end
      end
      # rubocop:enable Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Style/OptionalBooleanParameter
    end
  end
end
