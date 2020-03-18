# frozen_string_literal: true

module Decidim
  class BatchEmailNotificationGeneratorJob < ApplicationJob
    queue_as :scheduled

    def perform
      BatchEmailNotificationGenerator.new.generate
    end
  end
end
