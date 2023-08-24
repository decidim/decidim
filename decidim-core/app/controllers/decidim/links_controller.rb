# frozen_string_literal: true

module Decidim
  class InvalidUrlError < StandardError; end

  class LinksController < Decidim::ApplicationController
    skip_before_action :store_current_location

    helper Decidim::ExternalDomainHelper
    helper_method :external_url

    before_action :parse_url
    rescue_from Decidim::InvalidUrlError, with: :modal
    rescue_from URI::InvalidURIError, with: :modal

    def new
      headers["X-Robots-Tag"] = "noindex"
    end

    private

    def modal
      flash[:alert] = I18n.t("decidim.links.invalid_url")

      if request.xhr?
        render "modal"
      else
        redirect_to decidim.root_path
      end
    end

    def parse_url
      raise Decidim::InvalidUrlError if params[:external_url].blank?
      raise Decidim::InvalidUrlError unless external_url
      raise Decidim::InvalidUrlError unless %w(http https).include?(external_url.scheme)
    end

    def external_url
      @external_url ||= URI.parse(URI::Parser.new.escape(params[:external_url]))
    end
  end
end
