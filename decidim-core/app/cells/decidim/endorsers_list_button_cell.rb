# frozen_string_literal: true

module Decidim
  class EndorsersListButtonCell < RedesignedButtonCell
    def show
      return if model.endorsements.blank?

      render
    end

    private

    def button_classes
      "endorsers-list__trigger"
    end

    def html_options
      return {} if model.endorsements.blank?

      { id: "dropdown-trigger", data: { component: "dropdown", target: "dropdown-menu-endorsers-list" } }
    end
  end
end
