# frozen_string_literal: true

module Decidim
  # This cell renders the address of a meeting.
  class AddressCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include LayoutHelper

    def details
      render
    end

    private

    def resource_icon
      icon "meetings", class: "icon--big"
    end
  end
end
