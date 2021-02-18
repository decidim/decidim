# frozen_string_literal: true

module Decidim
  class LinksController < Decidim::ApplicationController
    helper Decidim::ExternalDomainHelper

    rescue_from Decidim::InvalidUrlError, with: :invalid_url

    def new
      headers["X-Robots-Tag"] = "noindex"
    end

    private

    def invalid_url
      flash[:alert] = I18n.t("decidim.links.invalid_url")
      redirect_to decidim.root_path
    end
  end
end
