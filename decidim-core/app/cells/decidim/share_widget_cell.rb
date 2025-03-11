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

    def title
      model.presenter.title(html_escape: true)
    end
  end
end
