# frozen_string_literal: true
module Decidim
  module Devise
    # Custom Devise PasswordsController to avoid namespace problems.
    class PasswordsController < ::Devise::PasswordsController
      include Decidim::DeviseControllers
    end
  end
end
