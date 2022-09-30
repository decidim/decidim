# frozen_string_literal: true

module Decidim
  class ShareButtonCell < RedesignedButtonCell
    private

    def button_classes
      "button button__sm button__text-secondary"
    end

    def text
      t("decidim.shared.share_modal.share")
    end

    def icon_name
      "share-line"
    end
  end
end
