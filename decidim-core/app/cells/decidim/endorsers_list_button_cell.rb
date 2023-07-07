# frozen_string_literal: true

module Decidim
  class EndorsersListButtonCell < ButtonCell
    private

    def button_classes
      "endorsers-list__trigger#{" hidden" if model.endorsements.blank?}"
    end

    def html_options
      { id: "dropdown-trigger", data: { component: "dropdown", target: "dropdown-menu-endorsers-list" } }
    end
  end
end
