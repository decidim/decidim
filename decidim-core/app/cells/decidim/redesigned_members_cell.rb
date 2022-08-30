# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  # Lists the members of the given user group.
  class RedesignedMembersCell < RedesignedFollowersCell
    def membership_cell_name
      return "decidim/user_group_admin_membership_profile" if options[:from_admin].presence

      "decidim/user_group_membership_profile"
    end

    def users
      @users ||= case options[:role].to_s
                 when "member"
                   Decidim::UserGroups::MemberMemberships.for(model).page(params[:page]).per(20)
                 when "admin"
                   Decidim::UserGroups::AdminMemberships.for(model).page(params[:page]).per(20)
                 else
                   Decidim::UserGroups::AcceptedMemberships.for(model).page(params[:page]).per(20)
                 end
    end

    def validation_messages
      [t("decidim.members.no_members")] if users.blank?
    end
  end
end
