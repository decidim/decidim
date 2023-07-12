# frozen_string_literal: true

module Decidim
  class ShareButtonCell < ButtonCell
    private

    def button_classes
      "button button__sm button__text-secondary"
    end

    def text
      t("decidim.shared.share_modal.share")
    end

    def icon_name
      resource_type_icon_key("share")
    end

    def html_options
      { data: { "dialog-open": "socialShare" } }
    end
  end
end
