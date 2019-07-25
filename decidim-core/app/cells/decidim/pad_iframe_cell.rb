# frozen_string_literal: true

module Decidim
  # This cell is used to render an iframe to embed an Etherpad from a
  # Paddable model.
  class PadIframeCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers

    def show
      return unless current_user
      return unless paddable.pad_is_visible?
      return if blank_read_only_pad?

      render
    end

    def iframe_id
      "etherpad-#{paddable.id}"
    end

    def iframe_url
      @iframe_url ||= [base_iframe_url, "?", url_options].join
    end

    def url_options
      URI.encode_www_form(
        userName: current_user.nickname,
        showControls: true,
        showLineNumbers: true,
        lang: current_user.locale
      )
    end

    def base_iframe_url
      return paddable.pad_public_url if paddable.pad_is_writable?

      paddable.pad_read_only_url
    end

    def paddable
      model
    end

    def current_organization
      current_user.organization
    end

    def blank_read_only_pad?
      paddable.pad_is_visible? && !paddable.pad_is_writable? && paddable.pad.text.blank?
    end
  end
end
