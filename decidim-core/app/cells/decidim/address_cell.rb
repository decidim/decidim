# frozen_string_literal: true

module Decidim
  # This cell renders the address of a meeting.
  class AddressCell < Decidim::ViewModel
    include Cell::ViewModel::Partial

    def show
      return render :online if options[:online]

      render
    end

    def has_location?
      model.respond_to?(:location)
    end

    def has_location_hints?
      model.respond_to?(:location_hints)
    end

    def location_hints
      decidim_sanitize_translated(model.location_hints)
    end

    def location
      decidim_sanitize_translated(model.location)
    end

    def address
      decidim_sanitize_translated(model.address)
    end
  end
end
