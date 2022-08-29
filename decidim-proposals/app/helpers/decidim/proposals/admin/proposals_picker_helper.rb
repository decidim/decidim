# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This class contains helpers needed to show the Proposals picker.
      #
      module ProposalsPickerHelper
        def proposals_picker(form, field, url)
          picker_options = {
            id: sanitize_to_id(field),
            class: "picker-multiple",
            name: "#{form.object_name}[#{field.to_s.sub(/s$/, "_ids")}]",
            multiple: true,
            autosort: true
          }

          prompt_params = {
            url:,
            text: t("proposals_picker.choose_proposals", scope: "decidim.proposals")
          }

          form.data_picker(field, picker_options, prompt_params) do |item|
            { url:, text: present(item).id_and_title }
          end
        end
      end
    end
  end
end
