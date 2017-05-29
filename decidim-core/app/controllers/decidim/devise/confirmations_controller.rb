# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise ConfirmationsController to avoid namespace problems.
    class ConfirmationsController < ::Devise::ConfirmationsController
      include Decidim::DeviseControllers
    end
  end
end
