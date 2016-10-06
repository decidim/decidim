# frozen_string_literal: true
module Decidim
  module System
    module Devise
      # Custom Passwords controller for Devise in order to use a custom layout
      # and views.
      class PasswordsController < ::Devise::PasswordsController
        layout "decidim/system/login"
      end
    end
  end
end
