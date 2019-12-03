# frozen_string_literal: true

module Decidim
  # This cell renders the endrosement button and the endorsements count.
  # It only supports one row of buttons per page due to current tag ids used by javascript.
  class EndorsementButtonsCell < Decidim::ViewModel
    include LayoutHelper
    include CellsHelper
    include EndorsableHelper

    delegate :current_user, to: :controller, prefix: false
    delegate :current_settings, to: :controller, prefix: false
    delegate :current_component, to: :controller, prefix: false
    delegate :allowed_to?, to: :controller, prefix: false

    def show
      render
    end

    # Renders the counter of endorsements that appears in card at show Propoal.
    def render_endorsements_count_card_part
      content = icon("bullhorn", class: "icon--small", aria_label: "Endorsements", role: "img")
      content += model.proposal_endorsements_count.to_s
      html_class = "button small compact light button--sc button--shadow "
      html_class += resource_fully_endorsed? ? "success" : "secondary"
      tag_params = { id: "proposal-#{model.id}-endorsements-count", class: html_class }
      if model.proposal_endorsements_count.positive?
        link_to "#list-of-endorsements", tag_params do
          content
        end
      else
        content_tag(:div, tag_params) do
          content
        end
      end
    end

    def render_endorsements_button_card_part(_fully_endorsed, html_class = nil)
      endorse_translated = t("decidim.endorsement_cell.render_endorsements_button_card_part.endorse")
      html_class = "card__button button" if html_class.blank?
      if current_settings.endorsements_blocked? || !current_component.participatory_space.can_participate?(current_user)
        content_tag :span, endorse_translated, class: "#{html_class} #{endorsement_button_classes(false)} disabled", disabled: true, title: endorse_translated
      elsif current_user && allowed_to?(:create, :endorsement, resource: resource)
        render "endorsement_identities_cabin"
      elsif current_user
        button_to(endorse_translated, proposal_path(proposal),
                  data: { open: "authorizationModal", "open-url": modal_path(:endorse, resource) },
                  class: "#{html_class} #{endorsement_button_classes(false)} secondary")
      else
        action_authorized_button_to :endorse, endorse_translated, "", resource: proposal, class: "#{html_class} #{endorsement_button_classes(false)} secondary"
      end
    end

    def refresh_url
      "identities_proposal_proposal_endorsement_path(proposal)"
    end

    def date
      render
    end

    def flag
      render
    end

    # The resource being un/endorsed is the Cell's model.
    def resource
      model
    end

    private

    def resource_fully_endorsed?
      fully_endorsed?(model, current_user)
    end

    def from_context_path
      resource_locator(from_context).path
    end

    def withdraw_path
      return decidim.withdraw_amend_path(from_context.amendment) if from_context.emendation?

      from_context_path + "/withdraw"
    end

    def creation_date?
      return true if posts_controller?
      return unless from_context
      return unless proposals_controller? || collaborative_drafts_controller?
      return unless show_action?

      true
    end

    def raw_model
      model.try(:__getobj__) || model
    end
  end
end
