# frozen_string_literal: true

module Decidim
  class HomepageController < Decidim::ApplicationController
    skip_before_action :store_current_location

    def show
      enforce_permission_to :read, :homepage
    end
  end
end
