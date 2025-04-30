# frozen_string_literal: true

module Decidim
  class ProfileActionsCell < ProfileCell
    include CellsHelper
    include Decidim::Messaging::ConversationHelper

    delegate :user_signed_in?, to: :controller

    ACTIONS_ITEMS = {
      edit_profile: { icon: "pencil-line", path: :account_path },
      message: { icon: "mail-send-line", path: :new_conversation_path },
      disabled_message: { icon: "mail-send-line", options: { html_options: { disabled: true, title: I18n.t("decidim.user_contact_disabled") } } }
    }.freeze

    private

    def action_item(key, translations_scope: "decidim.profiles.user.actions")
      return if ACTIONS_ITEMS[key].blank?

      values = ACTIONS_ITEMS[key].dup
      values[:options] = values.delete(:options) || {}
      return values if values.has_key?(:cell)

      values[:path] = send(values[:path]) if values[:path].present?
      values[:text] = t(key, scope: translations_scope)
      values
    end

    def new_conversation_path
      current_or_new_conversation_path_with(profile_holder)
    end

    def actions_keys
      @actions_keys ||= [].tap do |keys|
        keys << :edit_profile if own_profile?
        keys << message_key if can_contact_user?
      end
    end

    def message_key
      return :message if current_or_new_conversation_path_with(presented_profile).present?

      :disabled_message
    end

    def profile_actions
      actions = actions_keys.map { |key| action_item(key) }.compact
      return if actions.blank?

      render locals: { actions: }
    end

    def can_contact_user?
      !current_user || (current_user && current_user != model && presented_profile.can_be_contacted?)
    end
  end
end
