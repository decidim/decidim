# frozen_string_literal: true

module Decidim
  # This helper includes methods to generate modal windows on the layout.
  # The trigger element must contain a "data-dialog-open" attribute,
  # you may specify data-dialog-open="<seed>" also, where seed must match with
  # the provided id option: <%= decidim_modal id: seed %>. In a very similar way,
  # you also can add your custom close button through data-dialog-close="<seed>"
  #
  # Options available:
  #  - id: String. Unique identificator for the dialog, if the page has distinct modal windows (default: "")
  #  - class: String. CSS classes for the modal content.
  #  - closable: Boolean. Whether the modal can be closed or not (default: true)
  module ModalHelper
    def decidim_modal(opts = {}, &)
      opts[:closable] = true unless opts.has_key?(:closable)

      button = if opts[:closable] == false
                 ""
               else
                 content_tag(
                   :button,
                   "&times".html_safe,
                   type: :button,
                   data: { dialog_close: opts[:id] || "", dialog_closable: "" },
                   "aria-label": t("close_modal", scope: "decidim.shared.confirm_modal")
                 )
               end

      content = opts[:remote].nil? ? button + capture(&).html_safe : button + icon("loader-3-line")
      content_tag(:div, id: opts[:id], data: { dialog: opts[:id] || "" }.merge(opts[:data] || {})) do
        content_tag(:div, id: "#{opts[:id]}-content", class: opts[:class]) do
          content
        end
      end
    end
  end
end
