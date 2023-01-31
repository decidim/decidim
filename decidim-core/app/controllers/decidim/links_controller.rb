# frozen_string_literal: true

module Decidim
  class InvalidUrlError < StandardError; end

  class LinksController < Decidim::ApplicationController
    skip_before_action :store_current_location

    helper Decidim::ExternalDomainHelper
    helper_method :external_url

    before_action :parse_url
    rescue_from Decidim::InvalidUrlError, with: :invalid_url
    rescue_from URI::InvalidURIError, with: :invalid_url

    def new
      headers["X-Robots-Tag"] = "noindex"
    end

    private

    def invalid_url
      flash[:alert] = I18n.t("decidim.links.invalid_url")
      redirect_to decidim.root_path
    end

    def parse_url
      raise Decidim::InvalidUrlError unless external_url

      parts = external_url.match %r{\A(([a-z]+):)?//([^/]+)(/.*)?\z}
      raise Decidim::InvalidUrlError unless parts

      @url_parts = {
        protocol: parts[1],
        domain: parts[3],
        path: parts[4]
      }
    end

    def external_url
      @external_url ||= URI.parse(params[:external_url]).to_s
    end
  end
end
