# frozen_string_literal: true

module Decidim
  # A Helper to render and link amendments to resources.
  module AmendmentsHelper
    def amendments_enabled?
      current_component.settings.amendments_enabled
    end

    def amend_button_for(amendable)
      cell "decidim/amendable/amend_button_card", amendable if amendable.amendable?
    end

    # Renders the emendations of a amendable resource that includes the
    # Amendable concern.
    #
    # amendable - The resource that has emendations.
    #
    # Returns Html grid of CardM.
    def amendments_for(amendable)
      return unless amendments_enabled? && amendable.emendations.count
      return if amendable.emendation?
      content = content_tag :h2, class: "section-heading", id: "amendments" do
        t("section_heading", scope: "decidim.amendments.amendable", count: amendable.emendations.count)
      end

      content += if amendable.emendations.count.positive?
                   cell(
                     "decidim/collapsible_list",
                     amendable.emendations,
                     cell_options: { context: { current_user: current_user } },
                     list_class: "row small-up-1 medium-up-2 card-grid",
                     size: 4
                   ).to_s
                 else
                   t("no_amendments", scope: "decidim.amendments.amendable", count: amendable.emendations.count)
                 end

      content_tag :div, content.html_safe, class: "section"
    end

    def amenders_for(amendable)
      amendable.amendments.map { |amendment| present(amendment.amender) }.uniq
    end

    def amenders_list_for(amendable)
      cell "decidim/amendable/amenders_list", amenders_for(amendable), context: { current_user: current_user } if amendable.amendable?
    end

    # Renders the state of an emendation
    #
    # emendation - The resource that is an emendation.
    #
    # Returns Html callout.
    def emendation_announcement_for(emendation)
      cell "decidim/amendable/announcement", emendation if emendation.emendation?
    end

    # Returns Html action button cards: accept/reject or promote
    #
    # emendation - The resource that is an emendation.
    def emendation_actions_for(emendation)
      return unless allowed_to_react_to_emendation?(emendation)
      return accept_and_reject_buttons_for(emendation) if allowed_to_accept_and_reject?(emendation)
      return promote_button_for(emendation) if allowed_to_promote?(emendation)
    end

    # Renders the buttons to accept/reject an emendation
    def accept_and_reject_buttons_for(emendation)
      cell("decidim/amendable/emendation_actions", emendation)
    end

    # Renders the button to promote an emendation
    def promote_button_for(emendation)
      cell("decidim/amendable/promote_button_card", emendation)
    end

    # Checks if current_user can react to the emendation
    #
    # Returns true or false
    def allowed_to_react_to_emendation?(emendation)
      return unless emendation.emendation?
      return unless current_user
      true
    end

    # Checks if current_user can accept and reject the emendation
    #
    # Returns true or false
    def allowed_to_accept_and_reject?(emendation)
      return unless emendation.amendment.evaluating?
      emendation.amendable.created_by?(current_user) || current_user.admin
    end

    # Checks if current_user can promote the emendation
    #
    # Returns true or false
    def allowed_to_promote?(emendation)
      return unless emendation.state == "rejected"
      return unless emendation.created_by?(current_user)
      not_yet_promoted(emendation)
    end

    # Checks whether the ActionLog created in the promote command exists.
    #
    # Returns true or false
    def not_yet_promoted(emendation)
      logs = Decidim::ActionLog.where(decidim_component_id: emendation.component)
                               .where(decidim_user_id: emendation.creator_author)
                               .where(action: "promote")
      logs.select { |l| l.extra["promoted_from"] == emendation.id }.empty?
    end

    def user_group_select_field(form, name)
      selected = @form.user_group_id.presence
      form.select(
        name,
        current_user.user_groups.verified.map { |g| [g.name, g.id] },
        selected: selected,
        include_blank: current_user.name,
        label: t("new.amendment_author", scope: "decidim.amendments")
      )
    end

    def emendation_ignored_field_value(key)
      0 if @form.emendation_type.constantize.columns_hash[key.to_s].type == :integer
      nil if key == :id
    end
  end
end
