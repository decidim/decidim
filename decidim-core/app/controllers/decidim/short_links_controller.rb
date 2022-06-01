# frozen_string_literal: true

module Decidim
  # Redirects users with short links to the correct location on the site.
  class ShortLinksController < Decidim::ApplicationController
    skip_before_action :store_current_location

    # The index action redirects the user to the application root in case
    # someone tries to request the short link URL without an identifier.
    def index
      redirect_to decidim.root_path, status: :moved_permanently
    end

    # Redirects the user to the target URL that the short link is set to
    # redirect to. Raises an ActionController::RoutingError in case a short link
    # does not exist with the given identifier.
    #
    # @raise [ActionController::RoutingError] if a short link does not exist
    #   with the given identifier
    def show
      raise ActionController::RoutingError, "Not Found" unless link

      redirect_to link.target_url, status: :moved_permanently
    end

    private

    # Fetches the link based on the provided identifier in the parameters.
    #
    # @return [Decidim::ShortLink] The short link matching the identifier
    def link
      @link ||= Decidim::ShortLink.find_by(identifier: params[:id])
    end
  end
end
