# frozen_string_literal: true

module Decidim
  # The controller to show the newsletter on the website.
  class NewslettersController < Decidim::ApplicationController
    skip_authorization_check

    layout "decidim/mailer"
    helper Decidim::SanitizeHelper
    include Decidim::NewslettersHelper

    helper_method :newsletter

    def show
      @user = current_user
      @organization = current_organization
      if newsletter.sent?
        @body = parse_interpolations(newsletter.body[I18n.locale.to_s], @user, newsletter.id)
      else
        redirect_to decidim.root_url(host: @organization.host)
      end
    end

    def newsletter
      @newsletter ||= collection.find(params[:id])
    end

    private

    def collection
      Newsletter.where(organization: current_organization)
    end
  end
end
