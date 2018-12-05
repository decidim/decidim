# frozen_string_literal: true

class RemoveProposalLinkedNotifications < ActiveRecord::Migration[5.2]
  def change
    Decidim::Notification.where(event_name: "decidim.events.accountability.proposal_linked").delete_all
  end
end
