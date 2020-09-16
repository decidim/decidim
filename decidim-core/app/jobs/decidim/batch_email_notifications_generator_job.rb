# frozen_string_literal: true

module Decidim
  class BatchEmailNotificationsGeneratorJob < ApplicationJob
    queue_as :scheduled

    def perform
      BatchEmailNotificationsGenerator.new.generate
    end
  end
end
