# frozen_string_literal: true

module Decidim
  module Api
    class TranslationController < Api::ApplicationController
      before_action :verify_authenticity_token

      def translate
        if params[:original].present? && params[:target].present?
          auth_key = current_organization.try(:deepl_api_key) || Rails.application.secrets.try(:deepl_api_key)

          target = params[:target]
          encode_text = CGI.escape(params[:original])

          uri = URI.parse("https://api.deepl.com/v2/translate?target_lang=#{target}&text=#{encode_text}&auth_key=#{auth_key}&tag_handling=xml")

          result = api_request(uri)

          render json: result
        else
          render json: { status: :params_missing }
        end
      end

      private

      def api_request(uri)
        request = Net::HTTP::Get.new(uri)
        request.content_type = "application/json"
        req_options = {
          use_ssl: uri.scheme == "https"
        }

        Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          req = http.request(request)
          return empty_response if req.body.empty?

          JSON.parse(req.body)
        end
      end

      def empty_response
        { status: :empty_response }
      end
    end
  end
end
