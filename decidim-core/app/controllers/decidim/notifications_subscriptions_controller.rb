# frozen_string_literal: true

module Decidim
  # The controller to handle the subscriptions to push notifications
  class NotificationsSubscriptionsController < Decidim::ApplicationController
    def create
      return unless current_user

      Decidim::NotificationsSubscription.find_or_create_by(auth: params[:subscription][:keys][:auth]) do |subscription|
        subscription.decidim_user_id = current_user.id
        subscription.endpoint = params[:subscription][:endpoint]
        subscription.p256dh = params[:subscription][:keys][:p256dh]
      end
    end
  end
end
