# frozen_string_literal: true

module Decidim
  # This cell renders a notification from a notifications collection

  class NotificationCell < Decidim::ViewModel
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::SanitizeHelper

    def show
      render :show
    end

    def notification_title
      notification.event_class_instance.notification_title
    rescue StandardError
      I18n.t("decidim.notifications.show.missing_event")
    end

    def participatory_space_link
      return unless notification.resource.respond_to?(:participatory_space)

      participatory_space = notification.resource.participatory_space
      link_to(
        decidim_html_escape(translated_attribute(participatory_space.title)),
        resource_locator(participatory_space).path
      )
    end

    private

    def notification
      @notification ||= Decidim::NotificationPresenter.new(model)
    end
  end
end
