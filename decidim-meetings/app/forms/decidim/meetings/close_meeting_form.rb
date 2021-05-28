# frozen_string_literal: true

module Decidim
  module Meetings
    # This class holds a Form to close a meeting from Decidim's public views.
    class CloseMeetingForm < Decidim::Form
      attribute :closing_report, String
      attribute :proposal_ids, Array[Integer]
      attribute :proposals
      attribute :closed_at, Decidim::Attributes::TimeWithZone, default: ->(_form, _attribute) { Time.current }
      attribute :locale

      validates :closing_report, presence: true

      # Private: Gets the proposals from the meeting and injects them to the form.
      #
      # Returns nothing.
      def map_model(model)
        self.proposal_ids = model.linked_resources(:proposals, "proposals_from_meeting").pluck(:id)
        presenter = MeetingPresenter.new(model)
        self.closing_report = presenter.closing_report(all_locales: false)
      end

      def proposals
        @proposals ||= Decidim.find_resource_manifest(:proposals)
                              .try(:resource_scope, current_component)
                              &.where(id: proposal_ids)
                              &.order(title: :asc)
      end
    end
  end
end
