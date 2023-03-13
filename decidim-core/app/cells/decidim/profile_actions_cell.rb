# frozen_string_literal: true

module Decidim
  class ProfileActionsCell < RedesignedProfileCell
    include CellsHelper
    include Decidim::Messaging::ConversationHelper

    delegate :user_signed_in?, to: :controller

    ACTIONS_ITEMS = {
      edit_profile: { icon: "pencil-line", path: :profile_edit_path },
      create_user_group: { icon: "team-line", path: :profile_new_group_path },
      edit_user_group: { icon: "team-line", path: :edit_group_path },
      message: { icon: "mail-send-line", path: :new_conversation_path },
      manage_user_group_users: { icon: "user-settings-line", path: :group_manage_users_path },
      manage_user_group_admins: { icon: "user-star-line", path: :group_manage_admins_path },
      invite_user: { icon: "user-add-line", path: :group_invites_path },
      join_user_group: { icon: "user-add-line", path: :group_join_requests_path, options: { method: :post } },
      leave_user_group: { icon: "logout-box-r-line", path: :leave_group_path, options: { method: :delete } }
    }.freeze

    def show
      return render :user_group_admin if can_edit_user_group_profile?

      render
    end

    private

    def action_item(key, translations_scope: "decidim.profiles.user.actions")
      return if ACTIONS_ITEMS[key].blank?

      values = ACTIONS_ITEMS[key].dup
      values[:options] = values.delete(:options) || {}
      return values if values.has_key?(:cell)

      values[:path] = send(values[:path], profile_holder.nickname) if values[:path].present?
      values[:text] = t(key, scope: translations_scope)
      values
    end

    def profile_edit_path(nickname)
      if own_profile?
        account_path
      elsif can_edit_user_group_profile?
        edit_group_path(nickname)
      end
    end

    def profile_new_group_path(_nickname)
      new_group_path
    end

    def new_conversation_path(_nickname)
      current_or_new_conversation_path_with(profile_holder)
    end

    def can_edit_user_group_profile?
      return false unless user_group?
      return false unless user_groups_enabled?
      return false unless current_user

      Decidim::UserGroups::ManageableUserGroups.for(current_user).include?(model)
    end

    def actions_keys
      [].tap do |keys|
        keys << :edit_profile if own_profile?
        keys << :create_user_group if own_profile? && user_groups_enabled?
        # keys << :edit_user_group if can_edit_user_group_profile?
        keys << :message if can_contact_user?
        # keys.append(:manage_user_group_users, :manage_user_group_admins, :invite_user) if can_edit_user_group_profile?
        keys << :join_user_group if can_join_user_group?
        keys << :leave_user_group if can_leave_group?
      end
    end

    def user_group_admin_actions_keys
      # [].tap do |keys|
      #   keys << :message if can_contact_user?
      # end

      [].tap do |keys|
        # keys << :create_user_group if own_profile? && user_groups_enabled?
        keys << :edit_user_group if can_edit_user_group_profile?
        keys.append(:manage_user_group_users, :manage_user_group_admins, :invite_user) if can_edit_user_group_profile?
        # keys << :join_user_group if can_join_user_group?
        keys << :leave_user_group if can_leave_group?
      end.map { |key| action_item(key) }.compact
    end

    def profile_actions
      actions_keys.map { |key| action_item(key) }.compact
    end

    def user_group?
      profile_holder.is_a?(Decidim::UserGroup)
    end

    def can_leave_group?
      return false unless user_group?
      return false unless current_user

      Decidim::UserGroupMembership.exists?(user: current_user, user_group: model)
    end

    def can_join_user_group?
      return false unless user_group?
      return false unless current_user

      !Decidim::UserGroupMembership.exists?(user: current_user, user_group: model)
    end

    def group_member?
      Decidim::UserGroupMembership.exists?(user: current_user, user_group: model)
    end

    def can_contact_user?
      !own_profile? && presented_profile.can_be_contacted? && current_or_new_conversation_path_with(presented_profile).present?
    end
  end
end
