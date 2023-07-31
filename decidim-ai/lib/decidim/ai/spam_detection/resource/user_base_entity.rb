# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class UserBaseEntity < Base
          def fields = [:about]

          protected

          def query = Decidim::UserBaseEntity.includes(:user_moderation)
        end
      end
    end
  end
end
