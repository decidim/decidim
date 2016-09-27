# frozen_string_literal: true
module Decidim
  module System
    module Devise
      # A controller so admins can recover their passwords.
      class PasswordsController < ::Devise::PasswordsController
        layout "decidim/system/login"
      end
    end
  end
end
