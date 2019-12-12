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
    end
  end
end
