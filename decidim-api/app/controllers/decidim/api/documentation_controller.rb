# frozen_string_literal: true

module Decidim
  module Api
    # This controller takes queries from an HTTP endpoint and sends them out to
    # the Schema to be executed, later returning the response as JSON.
    class DocumentationController < Api::ApplicationController
      layout "decidim/api/documentation"
    end
  end
end
