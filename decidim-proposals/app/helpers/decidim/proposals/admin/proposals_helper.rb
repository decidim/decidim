# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This class contains helpers needed to format Meetings
      # in order to use them in select forms for Proposals.
      #
      module ProposalsHelper
        include Decidim::Admin::ResourceScopeHelper

        # Public: A formatted collection of Meetings to be used
        # in forms.
        def meetings_as_authors_selected
          return unless @proposal.present? && @proposal.official_meeting?

          @meetings_as_authors_selected ||= @proposal.authors.pluck(:id)
        end

        def coauthor_presenters_for(proposal)
          proposal.authors.map do |identity|
            if identity.is_a?(Decidim::Organization)
              Decidim::Proposals::OfficialAuthorPresenter.new
            else
              present(identity)
            end
          end
        end

        def endorsers_presenters_for(proposal)
          proposal.endorsements.for_listing.map { |identity| present(identity.normalized_author) }
        end

        def proposal_complete_state(proposal)
          return humanize_proposal_state(proposal.internal_state).html_safe if proposal.answered? && !proposal.published_state?

          humanize_proposal_state(proposal.state).html_safe
        end

        def proposals_admin_filter_tree
          {
            t("proposals.filters.type", scope: "decidim.proposals") => {
              link_to(t("proposals", scope: "decidim.proposals.application_helper.filter_type_values"), q: ransak_params_for_query(is_emendation_true: "0"),
                                                                                                        per_page:) => nil,
              link_to(t("amendments", scope: "decidim.proposals.application_helper.filter_type_values"), q: ransak_params_for_query(is_emendation_true: "1"),
                                                                                                         per_page:) => nil
            },
            t("models.proposal.fields.state", scope: "decidim.proposals") =>
              Decidim::Proposals::Proposal::POSSIBLE_STATES.each_with_object({}) do |state, hash|
                if state == "not_answered"
                  hash[link_to((humanize_proposal_state state), q: ransak_params_for_query(state_null: 1), per_page:)] = nil
                else
                  hash[link_to((humanize_proposal_state state), q: ransak_params_for_query(state_eq: state), per_page:)] = nil
                end
              end,
            t("models.proposal.fields.category", scope: "decidim.proposals") => admin_filter_categories_tree(categories.first_class),
            t("proposals.filters.scope", scope: "decidim.proposals") => admin_filter_scopes_tree(current_component.organization.id)
          }
        end

        def proposals_admin_search_hidden_params
          return unless params[:q]

          tags = ""
          tags += hidden_field_tag "per_page", params[:per_page] if params[:per_page]
          tags += hidden_field_tag "q[is_emendation_true]", params[:q][:is_emendation_true] if params[:q][:is_emendation_true]
          tags += hidden_field_tag "q[state_eq]", params[:q][:state_eq] if params[:q][:state_eq]
          tags += hidden_field_tag "q[category_id_eq]", params[:q][:category_id_eq] if params[:q][:category_id_eq]
          tags += hidden_field_tag "q[scope_id_eq]", params[:q][:scope_id_eq] if params[:q][:scope_id_eq]
          tags.html_safe
        end

        def proposals_admin_filter_applied_filters
          html = []
          if params[:q][:is_emendation_true].present?
            html << tag.span(class: "label secondary") do
              tag = "#{t("filters.type", scope: "decidim.proposals.proposals")}: "
              tag += if params[:q][:is_emendation_true].to_s == "1"
                       t("amendments", scope: "decidim.proposals.application_helper.filter_type_values")
                     else
                       t("proposals", scope: "decidim.proposals.application_helper.filter_type_values")
                     end
              tag += icon_link_to("circle-x", url_for(q: ransak_params_for_query_without(:is_emendation_true), per_page:), t("decidim.admin.actions.cancel"),
                                  class: "action-icon--remove")
              tag.html_safe
            end
          end
          if params[:q][:state_null]
            html << tag.span(class: "label secondary") do
              tag = "#{t("models.proposal.fields.state", scope: "decidim.proposals")}: "
              tag += humanize_proposal_state "not_answered"
              tag += icon_link_to("circle-x", url_for(q: ransak_params_for_query_without(:state_null), per_page:), t("decidim.admin.actions.cancel"),
                                  class: "action-icon--remove")
              tag.html_safe
            end
          end
          if params[:q][:state_eq]
            html << tag.span(class: "label secondary") do
              tag = "#{t("models.proposal.fields.state", scope: "decidim.proposals")}: "
              tag += humanize_proposal_state params[:q][:state_eq]
              tag += icon_link_to("circle-x", url_for(q: ransak_params_for_query_without(:state_eq), per_page:), t("decidim.admin.actions.cancel"),
                                  class: "action-icon--remove")
              tag.html_safe
            end
          end
          if params[:q][:category_id_eq]
            html << tag.span(class: "label secondary") do
              tag = "#{t("models.proposal.fields.category", scope: "decidim.proposals")}: "
              tag += translated_attribute categories.find(params[:q][:category_id_eq]).name
              tag += icon_link_to("circle-x", url_for(q: ransak_params_for_query_without(:category_id_eq), per_page:), t("decidim.admin.actions.cancel"),
                                  class: "action-icon--remove")
              tag.html_safe
            end
          end
          if params[:q][:scope_id_eq]
            html << tag.span(class: "label secondary") do
              tag = "#{t("models.proposal.fields.scope", scope: "decidim.proposals")}: "
              tag += translated_attribute Decidim::Scope.where(decidim_organization_id: current_component.organization.id).find(params[:q][:scope_id_eq]).name
              tag += icon_link_to("circle-x", url_for(q: ransak_params_for_query_without(:scope_id_eq), per_page:), t("decidim.admin.actions.cancel"),
                                  class: "action-icon--remove")
              tag.html_safe
            end
          end
          html.join(" ").html_safe
        end

        def icon_with_link_to_proposal(proposal)
          icon, tooltip = if allowed_to?(:create, :proposal_answer, proposal:) && !proposal.emendation?
                            [
                              "comment-square",
                              t(:answer_proposal, scope: "decidim.proposals.actions")
                            ]
                          else
                            [
                              "info",
                              t(:show, scope: "decidim.proposals.actions")
                            ]
                          end
          icon_link_to(icon, proposal_path(proposal), tooltip, class: "icon--small action-icon--show-proposal")
        end
      end
    end
  end
end
