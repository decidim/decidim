# frozen_string_literal: true
# A controller so admins can log-in and use their backend.
class Decidim::System::Devise::SessionsController < Devise::SessionsController
  layout "decidim/system/login"
end
