# frozen_string_literal: true
module Decidim
  module System
    module Devise
      # Custom Sessions controller for Devise in order to use a custom layout
      # and views.
      class SessionsController < ::Devise::SessionsController
        layout "decidim/system/login"
      end
    end
  end
end
