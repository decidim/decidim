# frozen_string_literal: true

module Decidim
  class ErrorsController < ApplicationController
    authorize_resource :error_pages, class: false

    def not_found
      render status: :not_found
    end

    def internal_server_error
      render status: :internal_server_error
    end
  end
end
