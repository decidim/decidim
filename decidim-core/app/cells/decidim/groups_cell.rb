# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  class GroupsCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::LayoutHelper
    include Decidim::ApplicationHelper
    include Decidim::LayoutHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper

    def show
      render :show
    end

    def user_groups
      @user_groups ||= Decidim::UserGroups::AcceptedUserGroups.for(model).page(params[:page]).per(20)
    end

    def validation_messages
      [t("decidim.groups.no_user_groups")] if user_groups.blank?
    end
  end
end
