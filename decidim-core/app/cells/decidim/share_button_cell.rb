# frozen_string_literal: true

module Decidim
  class ShareButtonCell < ButtonCell
    private

    def text
      options[:button_text] || t("decidim.shared.share_modal.share")
    end

    def icon_name
      resource_type_icon_key("share")
    end

    def html_options
      { data: { "dialog-open": "socialShare" } }
    end
  end
end
