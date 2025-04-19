# frozen_string_literal: true

require "rqrcode"

module Decidim
  class ShareTextWidgetCell < Decidim::ViewModel
    include Decidim::SocialShareButtonHelper

    alias resource model

    def show
      render
    end

    def title
      t(:share_text, scope: "decidim.budgets.order.status", space_name:, component_url:)
    end

    def space_name
      translated_attribute(resource.participatory_space.title)
    end

    def component_url
      Decidim::ResourceLocatorPresenter.new(resource).url
    end
  end
end
