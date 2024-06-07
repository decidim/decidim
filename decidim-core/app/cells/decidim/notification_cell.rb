# frozen_string_literal: true

module Decidim
  # This cell renders a notification from a notifications collection

  class NotificationCell < Decidim::ViewModel
    include Decidim::Core::Engine.routes.url_helpers

    def show
      if notification.event_class_instance.try(:hidden_resource?)
        render :moderated
      else
        render :show
      end
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
        decidim_escape_translated(participatory_space.title),
        resource_locator(participatory_space).path
      )
    end

    def action
      @action ||= model.extra["action"] if model.extra && model.extra["action"].present?
    end

    def action_cell
      return unless action

      @action_cell ||= ("decidim/notification_actions/#{action["type"]}" if "Decidim::NotificationActions::#{action["type"].camelize}Cell".safe_constantize)
    end

    private

    def notification
      @notification ||= Decidim::NotificationPresenter.new(model)
    end
  end
end
