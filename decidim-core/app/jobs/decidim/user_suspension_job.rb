# frozen_string_literal: true

module Decidim
  class UserSuspensionJob < ApplicationJob
    queue_as :user_suspension

    def perform(user, justification)
      UserSuspensionMailer.notify(user, justification).deliver_now
    end
  end
end
