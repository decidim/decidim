# frozen_string_literal: true

module Decidim
  module Api
    # This controller takes queries from an HTTP endpoint and sends them out to
    # the Schema to be executed, later returning the response as JSON.
    class DocumentationController < Api::ApplicationController
      layout "decidim/api/documentation"

      helper_method :static_api_docs_content

      def show
        @page = params[:path] || ""
      end

      private

      def static_api_docs_content
        "public/static/api/docs/#{@page}/index"
      end
    end
  end
end
