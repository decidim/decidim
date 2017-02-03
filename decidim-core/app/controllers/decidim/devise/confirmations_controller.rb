# frozen_string_literal: true
module Decidim
  module Devise
    # Custom Devise ConfirmationsController to avoid namespace problems.
    class ConfirmationsController < ::Devise::ConfirmationsController
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      helper Decidim::TranslationsHelper
      helper Decidim::MetaTagsHelper

      layout "layouts/decidim/application"
    end
  end
end
