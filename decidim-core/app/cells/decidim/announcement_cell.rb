# frozen_string_literal: true

module Decidim
  # This cell renders an announcement
  # the `model` is spected to be a Hash with two keys:
  #  `announcement` is mandatory, its the message to show
  #  `callout_class` is optional, the css class modifier
  #
  # {
  #   announcement: { ... },
  #   callout_class: "warning"
  # }
  #
  class AnnouncementCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    def show
      return unless announcement.presence

      render :show
    end

    private

    def callout_class
      model[:callout_class] ||= "secondary"
    end

    def announcement
      model[:announcement]
    end
  end
end
