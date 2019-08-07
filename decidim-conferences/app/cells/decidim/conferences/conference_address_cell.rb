# frozen_string_literal: true

module Decidim
  # This cell renders the address of a conference.
  module Conferences
    class ConferenceAddressCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include LayoutHelper
    end
  end
end
