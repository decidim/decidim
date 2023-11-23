# frozen_string_literal: true

# i18n-tasks-use t('decidim.events.proposals.proposal_state_changed.affected_user.notification_title')
# i18n-tasks-use t('decidim.events.proposals.proposal_state_changed.affected_user.email_subject')
# i18n-tasks-use t('decidim.events.proposals.proposal_state_changed.affected_user.email_outro')
# i18n-tasks-use t('decidim.events.proposals.proposal_state_changed.affected_user.email_intro')
module Decidim
  module Proposals
    class ProposalStateChangedEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def resource_text
        translated_attribute(resource.answer)
      end

      def event_has_roles?
        true
      end

      def default_i18n_options
        super.merge({ state: })
      end

      def state
        if resource.emendation?
          humanize_proposal_state(model.state)
        else
          translated_attribute(resource.proposal_state&.title)
        end
      end
    end
  end
end
