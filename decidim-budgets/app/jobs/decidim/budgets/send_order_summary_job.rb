# frozen_string_literal: true

module Decidim
  module Budgets
    class SendOrderSummaryJob < ApplicationJob
      queue_as :default

      def perform(order)
        return unless order&.user&.email.present?

        OrderSummaryMailer.order_summary(order).deliver_now
      end
    end
  end
end
