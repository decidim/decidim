# frozen_string_literal: true

module Decidim
  module AccountHelper
    def has_authorizations?
      Authorization.where(user: current_user).any?
    end
  end
end
