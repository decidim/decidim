# frozen_string_literal: true

module Decidim
  module Api
    class JwtBlacklist < ApplicationRecord
      include ::Devise::JWT::RevocationStrategies::Denylist

      self.table_name = "decidim_api_jwt_blacklists"
    end
  end
end
