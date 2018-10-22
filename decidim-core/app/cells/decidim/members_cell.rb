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
      @memberships ||= case options[:role].to_s
                       when "member"
                         Decidim::UserGroups::MemberMemberships.for(model).page(params[:page]).per(20)
                       else
                         Decidim::UserGroups::AcceptedMemberships.for(model).page(params[:page]).per(20)
                       end
    end
  end
end
