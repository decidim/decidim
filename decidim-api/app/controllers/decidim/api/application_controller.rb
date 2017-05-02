# frozen_string_literal: true
module Decidim
  module Api
    # Base controller for `decidim-api`. All other controllers inherit from this.
    class ApplicationController < ::DecidimController
      skip_before_action :verify_authenticity_token
      include NeedsOrganization
    end
  end
end
