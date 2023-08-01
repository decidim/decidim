# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class UserBaseEntity < Base
          def fields = [:about]

          protected

          def query = Decidim::UserBaseEntity.includes(:user_moderation)

          def resource_hidden?(resource) = resource.class.included_modules.include?(Decidim::UserReportable) && resource.blocked?
        end
      end
    end
  end
end
