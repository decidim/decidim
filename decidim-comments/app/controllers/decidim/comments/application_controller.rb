# frozen_string_literal: true
module Decidim
  module Comments
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      # include NeedsOrganization

      protect_from_forgery with: :exception, prepend: true

      # layout "application"
    end
  end
end
