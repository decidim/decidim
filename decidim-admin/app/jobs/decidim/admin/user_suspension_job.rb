# frozen_string_literal: true

module Decidim
  module Admin
    class UserSuspensionJob < ApplicationJob
      queue_as :user_suspension

      def perform(user, token, justification)
        UserSuspensionMailer.notify(user, token, justification).deliver_now
      end
    end
  end
end
