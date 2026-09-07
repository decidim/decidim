# frozen_string_literal: true

class ChangeEventNameAndClassToRenameToPublishProposalEvent < ActiveRecord::Migration[5.1]
  def up
    # rubocop:disable-next Rails/SkipsModelValidations
    Decidim::Notification.where(event_name: "decidim.events.proposals.proposal_created")
                         .update_all(event_name: "decidim.events.proposals.proposal_published", event_class: "Decidim::Proposals::PublishProposalEvent")
  end

  def down
    # rubocop:disable-next Rails/SkipsModelValidations
    Decidim::Notification.where(event_name: "decidim.events.proposals.proposal_published")
                         .update_all(event_name: "decidim.events.proposals.proposal_created", event_class: "Decidim::Proposals::CreateProposalEvent")
  end
end
