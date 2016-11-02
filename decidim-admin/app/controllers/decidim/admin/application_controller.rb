# frozen_string_literal: true
module Decidim
  module Admin
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      include NeedsOrganization
      include NeedsAuthorization

      protect_from_forgery with: :exception, prepend: true

      def user_not_authorized_path
        decidim_admin.root_path
      end
    end
  end
end
