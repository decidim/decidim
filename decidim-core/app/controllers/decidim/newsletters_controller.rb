# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications dashboard.
  class NewslettersController < Decidim::ApplicationController
    skip_authorization_check

    layout "decidim/mailer"
    helper Decidim::SanitizeHelper
    include Decidim::NewslettersHelper

    def show
      @organization = current_organization
      @newsletter = collection.find(params[:id])

      @body = parse_interpolations(@newsletter.id, @newsletter.body[I18n.locale.to_s], current_user)
    end

    private

    def collection
      Newsletter.where(organization: current_organization)
    end
  end
end
