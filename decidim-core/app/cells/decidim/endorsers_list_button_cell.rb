# frozen_string_literal: true

module Decidim
  class EndorsersListButtonCell < RedesignedButtonCell
    private

    def button_classes
      "endorsers-list__trigger"
    end

    def html_options
      { data: { component: "dropdown", target: "dropdown-menu-endorsers-list" } }
    end
  end
end
