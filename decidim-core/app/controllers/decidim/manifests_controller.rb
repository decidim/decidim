# frozen_string_literal: true

module Decidim
  # A controller to serve the manifest file for PWA
  class ManifestsController < Decidim::ApplicationController
    def show
      organization_presenter = OrganizationPresenter.new(current_organization)
      render layout: false, locals: { organization_params: organization_presenter }, content_type: "application/manifest+json"
    end
  end
end
