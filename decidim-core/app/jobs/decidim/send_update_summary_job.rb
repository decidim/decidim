# frozen_string_literal: true

module Decidim
  class SendUpdateSummaryJob < ApplicationJob
    queue_as :default

    def perform(user, updates)
      UserUpdateMailer.notify(user, updates).deliver_now
    end
  end
end
