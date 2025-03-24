# frozen_string_literal: true

require "rqrcode"

module Decidim
  class ShareWidgetCell < Decidim::ViewModel
    include Decidim::QrCodeHelper
    include Decidim::SocialShareButtonHelper

    alias resource model

    def show
      render
    end

    def processed_params
      params.permit(:participatory_process_slug, :component_id, :id).to_h
    end

    def title
      model.presenter.title(html_escape: true)
    end
  end
end
