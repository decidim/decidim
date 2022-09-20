# frozen_string_literal: true

module Decidim
  class NotificationsCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::LayoutHelper
    include Decidim::Core::Engine.routes.url_helpers

    helper_method :notifications

    def show
      return render :validations if validation_messages.present?

      render :show
    end

    private

    def validation_messages
      return [] if notifications_with_resource.present?

      [t("decidim.notifications.no_notifications")]
    end

    def notifications_with_resource
      @notifications_with_resource ||= notifications.select(&:resource)
    end

    def notifications
      @notifications ||= model.notifications.includes(:resource).order(created_at: :desc).page(params[:page]).per(50)
    end
  end
end
