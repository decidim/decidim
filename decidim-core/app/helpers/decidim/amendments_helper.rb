# frozen_string_literal: true

module Decidim
  # A Helper to render and link amendments to resources.
  module AmendmentsHelper
    # Renders the emendations of an amendable resource
    #
    # Returns Html grid of CardM.
    def amendments_for(amendable)
      return unless amendable.amendable? && amendable.emendations.count.positive?

      content = content_tag(:h2, class: "section-heading", id: "amendments") do
        t("section_heading", scope: "decidim.amendments.amendable", count: amendable.emendations.count)
      end

      content << cell("decidim/collapsible_list",
                      amendable.emendations,
                      cell_options: { context: { current_user: current_user } },
                      list_class: "row small-up-1 medium-up-2 card-grid",
                      size: 4).to_s

      content_tag :div, content.html_safe, class: "section"
    end

    # Renders the amenders list of an amendable resource
    def amenders_list_for(amendable)
      return unless amendable.amendable?

      cell("decidim/amendable/amenders_list", amendable)
    end

    # Renders the state of an emendation
    #
    # Returns Html callout.
    def emendation_announcement_for(emendation)
      return unless emendation.emendation?

      cell("decidim/amendable/announcement", emendation)
    end

    # Returns Html action button card to AMEND an amendable resource
    def amend_button_for(amendable)
      return unless amendments_enabled? && amendable.amendable?

      cell("decidim/amendable/amend_button_card", amendable)
    end

    # Returns Html action button cards for an emendation
    def emendation_actions_for(emendation)
      return unless amendments_enabled? && can_react_to_emendation?(emendation)

      action_button_card_for(emendation)
    end

    # Returns Html action button cards to ACCEPT/REJECT or to PROMOTE an emendation
    def action_button_card_for(emendation)
      return accept_and_reject_buttons_for(emendation) if allowed_to_accept_and_reject?(emendation)
      return promote_button_for(emendation) if allowed_to_promote?(emendation)
    end

    # Renders the buttons to ACCEPT/REJECT an emendation
    def accept_and_reject_buttons_for(emendation)
      cell("decidim/amendable/emendation_actions", emendation)
    end

    # Renders the button to PROMOTE an emendation
    def promote_button_for(emendation)
      cell("decidim/amendable/promote_button_card", emendation)
    end

    def amendments_enabled?
      current_component.settings.amendments_enabled
    end

    # Checks if there's a user that can react to an emendation
    def can_react_to_emendation?(emendation)
      return unless current_user && emendation.emendation?

      true
    end

    # Checks if the user can accept and reject the emendation
    def allowed_to_accept_and_reject?(emendation)
      return unless emendation.amendment.evaluating?

      emendation.amendable.created_by?(current_user) || current_user.admin?
    end

    # Checks if the user can promote the emendation
    def allowed_to_promote?(emendation)
      return unless emendation.amendment.rejected? && emendation.created_by?(current_user)
      return if promoted?(emendation)

      true
    end

    # Checks if the unique ActionLog created in the promote command exists.
    def promoted?(emendation)
      logs = Decidim::ActionLog.where(decidim_component_id: emendation.component)
                               .where(decidim_user_id: emendation.creator_author)
                               .where(action: "promote")

      logs.select { |log| log.extra["promoted_from"] == emendation.id }.present?
    end

    # Renders a UserGroup select field in a form.
    def user_group_select_field(form, name)
      form.select(name,
                  current_user.user_groups.verified.map { |g| [g.name, g.id] },
                  selected: form.object.user_group_id.presence,
                  include_blank: current_user.name,
                  label: t("new.amendment_author", scope: "decidim.amendments"))
    end

    # Return the edited field value or presents the original attribute value in a form.
    def emendation_field_value(form, original, key)
      return params[:amendment][:emendation_params][key] if params[:amendment].present?

      present(form.object.send(original)).send(key)
    end
  end
end
