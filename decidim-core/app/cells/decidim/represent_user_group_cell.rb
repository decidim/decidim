# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on forms.
  class RepresentUserGroupCell < Decidim::ViewModel
    def show
      return unless show_cell?

      render :show
    end

    private

    def show_cell?
      return unless current_user && current_organization.user_groups_enabled?
      return unless Decidim::UserGroups::ManageableUserGroups.for(current_user).verified.any?

      true
    end

    def form
      model
    end

    def user_groups
      current_user.user_groups.verified.map { |g| [g.name, g.id] }
    end

    def selected
      form.object.user_group_id.presence
    end

    def checkbox_text
      I18n.t("represent_user_group", scope: "decidim.shared.represent_user_group")
    end

    def include_blank_text
      I18n.t("select_user_group", scope: "decidim.shared.represent_user_group")
    end
  end
end
