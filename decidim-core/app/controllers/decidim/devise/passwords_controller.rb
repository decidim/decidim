# frozen_string_literal: true
module Decidim
  module Devise
    # Custom Devise PasswordsController to avoid namespace problems.
    class PasswordsController < ::Devise::PasswordsController
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      layout "application"
    end
  end
end
