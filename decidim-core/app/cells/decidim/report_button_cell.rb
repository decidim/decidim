# frozen_string_literal: true

module Decidim
  class ReportButtonCell < RedesignedButtonCell
    private

    def button_classes
      "button button__sm button__text-secondary"
    end

    def text
      t("decidim.shared.flag_modal.report")
    end

    def icon_name
      "flag-line"
    end
  end
end
