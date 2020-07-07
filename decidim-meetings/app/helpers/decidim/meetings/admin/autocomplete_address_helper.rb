# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Helper to render autocomplete select for address fields
      module AutocompleteAddressHelper
        include TranslationsHelper

        def autocomplete_address(form, options = {})
          placeholder = options.fetch(:placeholder, t("placeholder", scope: "decidim.geocoder.autocomplete_address"))
          help_text = options.fetch(:help_text, t("help_text", scope: "decidim.geocoder.autocomplete_address"))
          label = options.fetch(:label, t("label", scope: "decidim.geocoder.autocomplete_address"))

          prompt_options = { url: decidim_api.geocoder_path, placeholder: placeholder }
          html_options = { label: label }
          
          safe_join([
            (form.autocomplete_select(:address, form.object.address, html_options, prompt_options) do |address|
              { value: translated_attribute(address), label: translated_attribute(address) }
            end),
            (content_tag :p, help_text, class: "help-text")
          ])
        end
      end
    end
  end
end
