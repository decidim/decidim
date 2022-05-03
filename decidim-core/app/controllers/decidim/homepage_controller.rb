# frozen_string_literal: true

module Decidim
  class HomepageController < Decidim::ApplicationController
    redesign active: true

    layout "layouts/decidim/application"
    skip_before_action :store_current_location

    def show; end
  end
end
