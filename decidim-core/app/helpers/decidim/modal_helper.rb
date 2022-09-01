# frozen_string_literal: true

module Decidim
  # This helper includes methods to generate modal windows
  # on the layout.
  module ModalHelper
    def with_modal(id, opts = {}, &)
      modal_class = opts[:class] || "modal"
      content_tag(:div, data: { dialog: id }) do
        content_tag(:div, class: modal_class) do
          content_tag(:button, "&times".html_safe, type: :button, data: { dialog_close: model.id, dialog_close_default: "" }) +
            yield.html_safe
        end
      end
    end

    def with_modal_dialog_open(id, opts = {}, &)
      content_tag(:div, opts.deep_merge(data: { dialog_open: id }), &)
    end
  end
end
