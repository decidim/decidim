# frozen_string_literal: true

module Decidim
  class ErrorsController < Decidim::ApplicationController
    skip_before_action :verify_authenticity_token, :tos_accepted_by_user
    skip_after_action :verify_same_origin_request

    def not_found
      render status: :not_found
    end

    def internal_server_error
      @info_hash = {
        user: current_user&.id || t(".unknown"),
        date_and_time: l(Time.current, format: "%Y-%m-%dT%H:%M:%S.%6N"),
        request_method: request.request_method,
        url: try(:request).original_url,
        reference: Decidim::LogReferenceGenerator.new(request).generate_reference
      }
      @plain_info = @info_hash.keys.map { |val| t(".#{val}") }.zip(@info_hash.values).map { |val| val.join(": ") }.join("\n")
      render status: :internal_server_error
    end
  end
end
