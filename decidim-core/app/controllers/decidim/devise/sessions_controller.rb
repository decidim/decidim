# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers

      def after_sign_out_path_for(user)
        request.referer || super
      end
    end
  end
end
