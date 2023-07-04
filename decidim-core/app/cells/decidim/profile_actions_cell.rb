# frozen_string_literal: true

module Decidim
  class ProfileActionsCell < ProfileCell
    include CellsHelper
    include Decidim::Messaging::ConversationHelper

    delegate :user_signed_in?, to: :controller

    ACTIONS_ITEMS = {
      edit_profile: { icon: "pencil-line", path: :profile_edit_path },
      create_user_group: { icon: "team-line", path: :profile_new_group_path },
      resend_email_confirmation_instructions: { icon: "share-forward-line", path: :group_email_confirmation_path, options: { method: :post } },
      edit_user_group: { icon: "team-line", path: :edit_group_path },
      message: { icon: "mail-send-line", path: :new_conversation_path },
      disabled_message: { icon: "mail-send-line", options: { html_options: { disabled: true, title: I18n.t("decidim.user_contact_disabled") } } },
      manage_user_group_users: { icon: "user-settings-line", path: :profile_group_members_path },
      manage_user_group_admins: { icon: "user-star-line", path: :profile_group_admins_path },
      invite_user: { icon: "user-add-line", path: :group_invites_path },
      join_user_group: { icon: "user-add-line", path: :group_join_requests_path, options: { method: :post } },
      leave_user_group: { icon: "logout-box-r-line", path: :leave_group_path, options: { method: :delete, data: { confirm: I18n.t("decidim.groups.actions.are_you_sure") } } }
    }.freeze

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
      @actions_keys ||= [].tap do |keys|
        keys << :edit_profile if own_profile?
        keys << :create_user_group if own_profile? && user_groups_enabled?
        keys << message_key if can_contact_user?
        keys << :join_user_group if can_join_user_group?
        keys << :leave_user_group if can_leave_group?
      end
    end

    def group_editor_actions_keys
      @group_editor_actions_keys ||= if can_edit_user_group_profile?
                                       [
                                         :edit_user_group,
                                         :manage_user_group_users,
                                         :manage_user_group_admins,
                                         :invite_user
                                       ].tap do |keys|
                                         keys.prepend(:resend_email_confirmation_instructions) if user_group_email_to_be_confirmed?
                                         keys << :join_user_group if can_join_user_group?
                                         keys << :leave_user_group if can_leave_group?
                                       end
                                     else
                                       []
                                     end
    end

    def message_key
      return :message if current_or_new_conversation_path_with(presented_profile).present?

      :disabled_message
    end

    def profile_actions
      actions = (actions_keys - group_editor_actions_keys).map { |key| action_item(key) }.compact
      return if actions.blank?

      render locals: { actions: }
    end

    def dropdown_actions
      return if group_editor_actions_keys.blank?

      actions = group_editor_actions_keys.map { |key| action_item(key) }.compact
      return if actions.blank?

      render locals: { actions: }
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

    def user_group_email_to_be_confirmed?
      return false unless user_group?
      return false unless current_user

      !model.confirmed?
    end

    def group_member?
      Decidim::UserGroupMembership.exists?(user: current_user, user_group: model)
    end

    def can_contact_user?
      !current_user || (current_user && current_user != model && presented_profile.can_be_contacted?)
    end
  end
end
