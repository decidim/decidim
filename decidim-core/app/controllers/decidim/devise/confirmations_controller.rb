# frozen_string_literal: true
module Decidim
  module Devise
    # Custom Devise ConfirmationsController to avoid namespace problems.
    class ConfirmationsController < ::Devise::ConfirmationsController
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      helper Decidim::TranslationsHelper

      layout "layouts/decidim/application"
    end
  end
end
