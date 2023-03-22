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
      raise Decidim::InvalidUrlError if params[:external_url].blank?
      raise Decidim::InvalidUrlError unless params[:external_url].match %r{\A(https?:)?//([^/]+)(/.*)?\z}
      raise Decidim::InvalidUrlError unless external_url

      @url_parts = {
        protocol: (external_url.scheme ? "#{external_url.scheme}:" : ""),
        domain: external_url.host,
        path: [
          external_url.path,
          (external_url.query ? "?#{external_url.query}" : ""),
          (external_url.fragment ? "##{external_url.fragment}" : "")
        ].join
      }
    end

    def external_url
      @external_url ||= begin
        # Simple way to avoid double encoded URI issues
        URI.parse(CGI.unescape(params[:external_url]))
        URI.parse(params[:external_url])
      end
    end
  end
end
