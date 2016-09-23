# frozen_string_literal: true
module Decidim
  module System
    module Devise
      # A controller so admins can log-in and use their backend.
      class SessionsController < ::Devise::SessionsController
        helper Decidim::System::ApplicationHelper
        layout "decidim/system/login"
      end
    end
  end
end
