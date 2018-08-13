# frozen_string_literal: true

module Decidim
  module Admin
    module OfficializationsHelper
      def profile_path(user)
        Decidim::Core::Engine.routes.url_helpers.profile_path(user&.nickname)
      end
    end
  end
end
