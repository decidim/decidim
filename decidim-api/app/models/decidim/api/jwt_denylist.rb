# frozen_string_literal: true

module Decidim
  module Api
    class JwtDenylist < ApplicationRecord
      include ::Devise::JWT::RevocationStrategies::Denylist

      self.table_name = :decidim_api_jwt_denylists
    end
  end
end
