# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  class GroupMembersCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper
    # include Decidim::Core::Engine.routes.url_helpers

    def show
      render :show
    end

    def memberships
      @memberships ||= Decidim::UserGroups::MemberMemberships.for(model).page(params[:page]).per(20)
    end

    def validation_messages
      [t("decidim.members.no_members")] if memberships.blank?
    end
  end
end
