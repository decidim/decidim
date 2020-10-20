# frozen_string_literal: true

module Decidim
  module Demographics
    module SignInRoutes
      def after_sign_in_path_for(user)
        current_organization.demographics_data_collection? ? demographics_engine.new_path : super
      end
    end
  end
end
