# frozen_string_literal: true

module Decidim
  # This cell renders a notification from a notifications collection

  class NotificationCell < Decidim::ViewModel
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers

    def show
      render :show
    end

    def notification_title
      notification.event_class_instance.notification_title
    rescue StandardError
      I18n.t("decidim.notifications.show.missing_event")
    end

    private

    def notification
      @notification ||= Decidim::NotificationPresenter.new(model)
    end
  end
end
