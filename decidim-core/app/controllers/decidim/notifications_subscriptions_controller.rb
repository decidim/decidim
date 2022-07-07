# frozen_string_literal: true

module Decidim
  # The controller to handle the subscriptions to push notifications
  class NotificationsSubscriptionsController < Decidim::ApplicationController
    def create
      Decidim::NotificationsSubscriptionsPersistor.new(current_user).add_subscription(params)
      head :ok
    end

    def destroy
      Decidim::NotificationsSubscriptionsPersistor.new(current_user).delete_subscription(params[:auth])
      head :ok
    end
  end
end
