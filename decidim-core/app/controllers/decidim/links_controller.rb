# frozen_string_literal: true

module Decidim
  class LinksController < Decidim::ApplicationController
    helper Decidim::ExternalDomainHelper

    def new
      headers["X-Robots-Tag"] = "noindex"
    end
  end
end
