# frozen_string_literal: true

module Decidim
  class ErrorsController < Decidim::ApplicationController
    skip_before_action :verify_authenticity_token, :tos_accepted_by_user
    skip_after_action :verify_same_origin_request

    def not_found
      render status: :not_found
    end

    def internal_server_error
      render status: :internal_server_error
    end
  end
end
