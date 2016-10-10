# frozen_string_literal: true
module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      layout "application"
    end
  end
end
