# frozen_string_literal: true

module Decidim
  class BatchEmailNotificationsGeneratorJob < ApplicationJob
    queue_as :scheduled

    def perform
      return unless Decidim.config.batch_email_notifications_enabled

      BatchEmailNotificationsGenerator.new.generate
    end
  end
end
