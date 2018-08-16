# frozen_string_literal: true

module Decidim
  module Admin
    module OfficializationsHelper
      def profile_path(user)
        decidim.profile_path(user&.nickname)
      end
    end
  end
end
