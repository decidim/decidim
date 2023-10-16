# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposals
    module ProposalsHelper
      def proposal_reason_callout_announcement
        {
          title: proposal_reason_callout_title,
          body: decidim_sanitize_editor_admin(translated_attribute(@proposal.answer))
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

      def proposal_has_costs?
        @proposal.cost.present? &&
          translated_attribute(@proposal.cost_report).present? &&
          translated_attribute(@proposal.execution_period).present?
      end

      def resource_version(resource, options = {})
        return unless resource.respond_to?(:amendable?) && resource.amendable?

        super
      end

      def export_dropdown(collection_ids = nil)
        raise "called"
        render partial: "decidim/proposals/admin/proposals/dropdown", locals: { collection_ids: }
      end

      def export_dropdowns(query)
        return export_dropdown if query.conditions.empty?

        export_dropdown.concat(export_dropdown(query.result.map(&:id)))
      end

      def dropdown_id(collection_ids)
        return "export-dropdown" if collection_ids.blank?

        "export-selection-dropdown"
      end
    end
  end
end
