# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  class StaticMapController < ApplicationController
    skip_authorization_check

    def show
      send_data StaticMapGenerator.new(resource).data, type: "image/jpeg", disposition: "inline"
    end

    private

    def resource
      @resource ||= GlobalID::Locator.locate_signed params[:sgid]
    end
  end
end
