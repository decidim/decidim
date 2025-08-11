# frozen_string_literal: true

module Decidim
  module System
    module ApiUsersHelper
      def fresh_token?(api_user)
        @secret_user.present? &&
          @secret_user[:id].present? &&
          @secret_user[:id] == api_user.id
      end

      def organizations
        Decidim::Organization.all
      end
    end
  end
end
