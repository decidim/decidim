# frozen_string_literal: true

module Decidim
  module Meetings
    # This class holds a Form to close a meeting from Decidim's public views.
    class CloseMeetingForm < Decidim::Form
      attribute :closing_report, String
      attribute :proposal_ids, Array[Integer]
      attribute :proposals
      attribute :closed_at, Decidim::Attributes::TimeWithZone, default: -> { Time.current }
      attribute :attendees_count, Integer

      validates :closing_report, presence: true
      validates :attendees_count,
                presence: true,
                numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999, only_integer: true }

      # Private: Gets the proposals from the meeting and injects them to the form.
      #
      # Returns nothing.
      def map_model(model)
        self.proposal_ids = model.linked_resources(:proposals, "proposals_from_meeting").pluck(:id)
        presenter = MeetingEditionPresenter.new(model)
        self.closing_report = presenter.closing_report(all_locales: false)
        self.attendees_count = model.attendees_count || model.registrations.where.not(validated_at: nil).count
      end

      def proposals
        @proposals = Decidim.find_resource_manifest(:proposals)
                            .try(:resource_scope, current_component)
                            &.where(id: proposal_ids)
                            &.order(title: :asc)
      end
    end
  end
end
