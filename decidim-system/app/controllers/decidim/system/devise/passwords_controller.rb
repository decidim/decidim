# frozen_string_literal: true
# A controller so admins can recover their passwords.
class Decidim::System::Devise::PasswordsController < Devise::PasswordsController
  layout "decidim/system/login"
end
