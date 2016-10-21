# frozen_string_literal: true
module Decidim
  module Api
    # Base controller for `decidim-api`. All other controllers inherit from this.
    class ApplicationController < ActionController::Base
      include NeedsOrganization
    end
  end
end
