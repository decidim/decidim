# frozen_string_literal: true

module Decidim
  # The controller to handle the subscriptions to push notifications
  class NotificationsSubscriptionsController < Decidim::ApplicationController
    def create
      return unless current_user

      Decidim::NotificationsSubscription.find_or_create_by(auth: params[:keys][:auth]) do |subscription|
        subscription.decidim_user_id = current_user.id
        subscription.endpoint = params[:endpoint]
        subscription.p256dh = params[:keys][:p256dh]
      end

      head :ok
    end

    def delete
      Decidim::NotificationsSubscription.where(decidim_user_id: current_user.id).destroy_all

      head :ok
    end
  end
end
