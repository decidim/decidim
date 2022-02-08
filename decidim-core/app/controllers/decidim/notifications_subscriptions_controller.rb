# frozen_string_literal: true

module Decidim
  # The controller to handle the subscriptions to push notifications
  class NotificationsSubscriptionsController < Decidim::ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      return unless current_user

      Decidim::NotificationsSubscription.find_or_create_by(auth: params[:keys][:auth]) do |subscription|
        subscription.decidim_user_id = current_user.id
        subscription.endpoint = params[:endpoint]
        subscription.p256dh = params[:keys][:p256dh]
      end

      head :ok
    end

    def delete_by_user
      Decidim::NotificationsSubscription.where(decidim_user_id: params[:user_id]).destroy_all

      head :ok
    end
  end
end
