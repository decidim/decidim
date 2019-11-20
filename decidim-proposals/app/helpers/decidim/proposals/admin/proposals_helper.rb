# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This class contains helpers needed to format Meetings
      # in order to use them in select forms for Proposals.
      #
      module ProposalsHelper
        # Public: A formatted collection of Meetings to be used
        # in forms.
        def meetings_as_authors_selected
          return unless @proposal.present? && @proposal.official_meeting?

          @meetings_as_authors_selected ||= @proposal.authors.pluck(:id)
        end

        def proposals_admin_filter_tree
          {
            t("proposals.filters.type", scope: "decidim.proposals") => {
              link_to(t("proposals", scope: "decidim.proposals.application_helper.filter_type_values"), q: ransak_params_for_query(is_emendation_true: "0")) => nil,
              link_to(t("amendments", scope: "decidim.proposals.application_helper.filter_type_values"), q: ransak_params_for_query(is_emendation_true: "1")) => nil
            },
            t("models.proposal.fields.state", scope: "decidim.proposals") =>
              Decidim::Proposals::Proposal::POSSIBLE_STATES.each_with_object({}) do |state, hash|
                if state == "not_answered"
                  hash[link_to((humanize_proposal_state state), q: ransak_params_for_query(state_null: 1))] = nil
                else
                  hash[link_to((humanize_proposal_state state), q: ransak_params_for_query(state_eq: state))] = nil
                end
              end,
            t("models.proposal.fields.category", scope: "decidim.proposals") => admin_filter_categories_tree(categories.first_class)
          }
        end
      end
    end
  end
end
