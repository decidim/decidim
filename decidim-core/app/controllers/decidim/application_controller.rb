# frozen_string_literal: true
module Decidim
  # The main application controller that inherits from Rails.
  class ApplicationController < ActionController::Base
    include Decidim::NeedsOrganization
    include Decidim::LocaleSwitcher
    include NeedsAuthorization
    protect_from_forgery with: :exception, prepend: true

    layout "application"

    def user_not_authorized_path
      decidim.root_path
    end
  end
end
