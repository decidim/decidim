# frozen_string_literal: true

module Decidim
  class WidgetsController < Decidim::ApplicationController
    skip_authorization_check only: :show
    skip_before_action :verify_authenticity_token
    after_action :allow_iframe, only: :show

    layout "decidim/widget"

    helper_method :model, :iframe_url, :current_featurable

    def show
      respond_to do |format|
        format.js { render "decidim/widgets/show" }
        format.html
      end
    end

    private

    def current_featurable
      @current_featurable ||= model.feature.featurable
    end

    def iframe_url
      raise NotImplementedError
    end

    def allow_iframe
      response.headers.delete "X-Frame-Options"
    end
  end
end
