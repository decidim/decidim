# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  # Lists the members of the given user group.
  class MembersCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper

    def show
      render :show
    end

    def memberships
      @memberships ||= case role
                       when "member"
                         Decidim::UserGroups::MemberMemberships.for(model).page(params[:page]).per(20)
                       when "admin"
                         Decidim::UserGroups::AdminMemberships.for(model).page(params[:page]).per(20)
                       else
                         Decidim::UserGroups::AcceptedMemberships.for(model).page(params[:page]).per(20)
                       end
    end

    def role
      options[:role].to_s
    end

    def validation_messages
      [t("decidim.members.no_members")] if memberships.blank?
    end
  end
end
