# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This class contains helpers needed to show the polling officers picker.
      module PollingOfficersPickerHelper
        def polling_officers_picker(form, field, url)
          picker_options = {
            id: sanitize_to_id(field),
            class: "picker-multiple",
            name: "#{form.object_name}[#{field.to_s.sub(/s$/, "_ids")}]",
            multiple: true,
            autosort: true
          }

          prompt_params = {
            url:,
            text: t("polling_officers_picker.choose_polling_officers", scope: "decidim.votings.admin.polling_officers")
          }

          form.data_picker(field, picker_options, prompt_params) do |item|
            { url:, text: item.name }
          end
        end
      end
    end
  end
end
