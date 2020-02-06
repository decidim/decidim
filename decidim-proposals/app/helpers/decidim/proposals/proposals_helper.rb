# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposals
    module ProposalsHelper
      def proposal_reason_callout_args
        {
          announcement: {
            title: proposal_reason_callout_title,
            body: decidim_sanitize(translated_attribute(@proposal.answer))
          },
          callout_class: proposal_reason_callout_class
        }
      end

      def proposal_reason_callout_class
        case @proposal.state
        when "accepted"
          "success"
        when "evaluating"
          "warning"
        when "rejected"
          "alert"
        else
          ""
        end
      end

      def proposal_reason_callout_title
        i18n_key = case @proposal.state
                   when "evaluating"
                     "proposal_in_evaluation_reason"
                   else
                     "proposal_#{@proposal.state}_reason"
                   end

        t(i18n_key, scope: "decidim.proposals.proposals.show")
      end

      def filter_proposals_state_values
        Decidim::ChainedCheckBoxesHelper::TreeNode.new(
          Decidim::ChainedCheckBoxesHelper::TreePoint.new("", t("decidim.proposals.application_helper.filter_state_values.all")),
          [
            Decidim::ChainedCheckBoxesHelper::TreePoint.new("accepted", t("decidim.proposals.application_helper.filter_state_values.accepted")),
            Decidim::ChainedCheckBoxesHelper::TreePoint.new("evaluating", t("decidim.proposals.application_helper.filter_state_values.evaluating")),
            Decidim::ChainedCheckBoxesHelper::TreePoint.new("not_answered", t("decidim.proposals.application_helper.filter_state_values.not_answered")),
            Decidim::ChainedCheckBoxesHelper::TreePoint.new("rejected", t("decidim.proposals.application_helper.filter_state_values.rejected"))
          ]
        )
      end

      def scopes_picker_filter_depth(form, name, checkboxes_on_top = true)
        options = {
          multiple: true,
          legend_title: I18n.t("decidim.scopes.scopes"),
          label: false,
          checkboxes_on_top: checkboxes_on_top
        }

        form.scopes_picker name, options do |scope|
          {
            url: decidim.scopes_picker_path(
              root: try(:current_participatory_space)&.scope,
              current: scope&.id,
              title: I18n.t("decidim.scopes.prompt"),
              global_value: "global",
              max_depth: try(:current_participatory_space)&.scope_type_max_depth
            ),
            text: scope_name_for_picker(scope, I18n.t("decidim.scopes.prompt"))
          }
        end
      end
    end
  end
end
