# frozen_string_literal: true

module Decidim
  # This class manages the creation and deletion of user notifications

  class NotificationsSubscriptionsPersistor
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def add_subscription(params)
      subscriptions = user.notification_settings["subscriptions"] || {}
      filtered_params = filter_params(params)
      new_subscription = { filtered_params[:auth] => filtered_params }
      user.notification_settings["subscriptions"] = subscriptions.merge(new_subscription)
      user.save
    end

    def delete_subscription(auth_key)
      subscriptions = user.notification_settings["subscriptions"] || {}
      user.notification_settings["subscriptions"] = subscriptions.except(auth_key)
      user.save
    end

    private

    def filter_params(params)
      {
        auth: params[:keys][:auth],
        p256dh: params[:keys][:p256dh],
        endpoint: params[:endpoint]
      }
    end
  end
end
