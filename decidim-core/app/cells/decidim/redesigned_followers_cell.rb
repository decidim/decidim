# frozen_string_literal: true

module Decidim
  class RedesignedFollowersCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::ApplicationHelper
    include Decidim::LayoutHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper

    def show
      return render :validations if validation_messages.present?

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
