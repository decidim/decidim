# frozen_string_literal: true

module Decidim
  # We serve a custom /favicon.ico route for Decidim in order to show the
  # correct favicons also when browsing e.g. PDF documents originating from the
  # same domain displayed inline in the browser. For those special files
  # displayed in the browser, the favicon could be otherwise incorrectly sohwn
  # or cached.
  #
  # This custom route ensures that the favicons are always correctly served for
  # the domain.
  class FaviconController < ::DecidimController
    include ActionController::DataStreaming # For Rails 7, check out `ActiveStorage::Streaming`.
    include NeedsOrganization

    skip_before_action :verify_authenticity_token, :verify_organization
    skip_after_action :verify_same_origin_request

    after_action :skip_headers

    def show
      response.headers["Content-Type"] = "image/vnd.microsoft.icon"
      response.headers["Content-Disposition"] = %(inline; filename="favicon.ico")
      return render_blank_favicon unless favicon_blob
      return unless stale?(favicon_blob, public: true, last_modified: favicon_blob.created_at)

      expires_in 1.week, public: true

      # For Rails 7, check out `send_blob_stream`.
      favicon_blob.download do |chunk|
        response.stream.write(chunk)
      end
    end

    private

    def skip_headers
      # Disable the session cookie header for the favicon request
      request.session_options[:skip] = true
      # Disable the default headers
      Rails.application.config.action_dispatch.default_headers.keys.each do |header|
        response.headers.delete(header)
      end
    end

    def render_blank_favicon
      response.stream.write("")
    end

    def favicon_blob
      return unless current_organization

      @favicon_blob ||= current_organization.favicon_ico&.blob
    end
  end
end
