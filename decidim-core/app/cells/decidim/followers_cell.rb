# frozen_string_literal: true

module Decidim
  class FollowersCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper

    def show
      render :show
    end

    def followers
      @followers ||= model.followers.not_blocked.page(params[:page]).per(20)
    end

    def validation_messages
      [t("decidim.followers.no_followers")] if followers.blank?
    end
  end
end
