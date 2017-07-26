# frozen_string_literal: true

module Decidim
  module Admin
    class ExpireImpersonationJob < ApplicationJob
      queue_as :default

      def perform(user, current_user)
        CloseSessionManagedUser.call(user, current_user)
      end
    end
  end
end
