# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to close a meeting from Decidim's admin panel.
      class CloseMeetingForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :closing_report, Decidim::Attributes::RichText
        attribute :video_url, String
        attribute :audio_url, String
        attribute :closing_visible, Boolean, default: true
        attribute :attendees_count, Integer
        attribute :contributions_count, Integer, default: 0
        attribute :attending_organizations, String
        attribute :proposal_ids, Array[Integer]
        attribute :proposals
        attribute :closed_at, Decidim::Attributes::TimeWithZone, default: -> { Time.current }

        validates :closing_report, translatable_presence: true
        validates :attendees_count, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999, only_integer: true }
        validates :contributions_count, numericality: true, allow_blank: true

        # Private: Gets the proposals from the meeting and injects them to the form.
        #
        # Returns nothing.
        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "proposals_from_meeting").pluck(:id)
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
end
