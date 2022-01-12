# frozen_string_literal: true

module Decidim
  module Api
    # This controller takes queries from an HTTP endpoint and sends them out to
    # the Schema to be executed, later returning the response as JSON.
    class DocumentationController < Api::ApplicationController
      layout "decidim/api/documentation"

      helper_method :static_api_docs_content
      before_action :set_cache_headers

      private

      def static_api_docs_content
        render_to_string(File.join("static", "api", "docs", *safe_content_path, "index"), layout: false)
      end

      def safe_content_path
        return "" unless params[:path]

        params[:path].split("/").excluding("..", ".")
      end

      def set_cache_headers
        response.headers["Cache-Control"] = "no-cache, no-store"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
      end
    end
  end
end
