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
      return pending_location_text if model.respond_to?(:pending_location?) && model.pending_location?

      decidim_sanitize_translated(model.location)
    end

    def address
      decidim_sanitize_translated(model.address) if model.respond_to?(:address) && model.address.present?
    end

    def pending_location_text
      t("show.pending_address", scope: "decidim.meetings.meetings")
    end

    def display_start_and_end_time?
      model.respond_to?(:start_time) && model.respond_to?(:end_time)
    end

    def start_and_end_time
      <<~HTML
        #{with_tooltip(l(model.start_time, format: :tooltip)) { start_time }}
        -
        #{with_tooltip(l(model.end_time, format: :tooltip)) { end_time }}
      HTML
    end

    def online_meeting_url
      URI::Parser.new.escape(model.online_meeting_url)
    end

    def display_online_meeting_url?
      return true unless model.respond_to?(:online?)
      return true unless model.respond_to?(:iframe_access_level_allowed_for_user?)

      model.online? && model.iframe_access_level_allowed_for_user?(current_user)
    end

    private

    def start_time
      l model.start_time, format: "%H:%M %p"
    end

    def end_time
      l model.end_time, format: "%H:%M %p %Z"
    end
  end
end
