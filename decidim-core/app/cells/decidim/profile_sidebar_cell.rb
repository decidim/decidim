# frozen_string_literal: true

module Decidim
  class ProfileSidebarCell < Decidim::ProfileCell
    include Decidim::Messaging::ConversationHelper
    include Decidim::IconHelper
    include Decidim::ViewHooksHelper
    include Decidim::ApplicationHelper
    include Decidim::SanitizeHelper
    include Decidim::CellsHelper

    helper_method :profile_user, :logged_in?, :current_user

    delegate :user_signed_in?, to: :controller

    def show
      render :show
    end

    private

    def logged_in?
      current_user.present?
    end

    def profile_user
      @profile_user ||= present(model)
    end

    def can_contact_user?
      !current_user || (current_user && current_user != model && profile_user.can_be_contacted?)
    end

    def officialization_text
      profile_user.officialization_text
    end

    def can_edit_user_group_profile?
      return false unless current_user
      return false if model.is_a?(Decidim::User)

      Decidim::UserGroups::ManageableUserGroups.for(current_user).include?(model)
    end

    def profile_user_can_follow?
      profile_user.can_follow?
    end

    def badge_statuses
      Decidim::Gamification.badges.select { |badge| badge.valid_for?(profile_holder) }.map do |badge|
        status = Decidim::Gamification.status_for(profile_holder, badge.name)
        status.level.positive? ? status : nil
      end.compact
    end

    def can_join_user_group?
      return false unless current_user
      return false if model.is_a?(Decidim::User)

      Decidim::UserGroupMembership.where(user: current_user, user_group: model).empty?
    end

    def can_leave_group?
      return false unless current_user
      return false if model.is_a?(Decidim::User)

      Decidim::UserGroupMembership.where(user: current_user, user_group: model).any?
    end

    def user_group_email_to_be_confirmed?
      return false unless current_user
      return false if model.is_a?(Decidim::User)

      !model.confirmed?
    end
  end
end
