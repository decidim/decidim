# frozen_string_literal: true

module Decidim
  module System
    module ApiUsersHelper
      def fresh_token?(api_user)
        params["token"].present? &&
          params["api_user"].present? &&
          params["api_user"] == api_user.id.to_s
      end

      def organizations
        Decidim::Organization.all
      end
    end
  end
end
