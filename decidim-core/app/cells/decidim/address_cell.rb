# frozen_string_literal: true

module Decidim
  # This cell renders the address of a meeting.
  class AddressCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include LayoutHelper
    include Decidim::SanitizeHelper

    def show
      render
    end

    def has_location?
      model.respond_to?(:location)
    end

    def has_location_hints?
      model.respond_to?(:location_hints)
    end

    def location_hints
      decidim_sanitize(translated_attribute(model.location_hints))
    end

    def location
      decidim_sanitize(translated_attribute(model.location))
    end

    def address
      decidim_sanitize(translated_attribute(model.address))
    end

    private

    # deprecated
    def resource_icon
      icon "meetings", class: "icon--big", role: "img", "aria-hidden": true
    end
  end
end
