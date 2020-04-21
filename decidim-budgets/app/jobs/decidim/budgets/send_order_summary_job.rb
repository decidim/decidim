# frozen_string_literal: true

module Decidim
  module Budgets
    class SendOrderSummaryJob < ApplicationJob
      queue_as :default

      def perform(order)
        return unless order
        return unless order.user
        return if order.user.email.blank?

        OrderSummaryMailer.order_summary(order).deliver_now
      end
    end
  end
end
