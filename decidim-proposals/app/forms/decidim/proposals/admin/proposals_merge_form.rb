# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users wants to merge two or more
      # proposals into a new one to another proposal component in the same space.
      class ProposalsMergeForm < ProposalBaseForm
        include Decidim::HasUploadValidations
        include Decidim::AttachmentAttributes
        translatable_attribute :title, String do |field, _locale|
          validates field, length: { in: 15..150 }, if: proc { |resource| resource.send(field).present? }
        end
        translatable_attribute :body, Decidim::Attributes::RichText
        attribute :target_component_id, Array[Integer]
        attribute :proposal_ids, Array

        attachments_attribute :documents

        validates :target_component, :proposals, :current_component, presence: true
        validates :proposal_ids, length: { minimum: 2 }
        validates :title, :body, translatable_presence: true
        validate :mergeable_to_same_component
        validate :notify_missing_attachment_if_errored

        def proposals
          @proposals ||= Decidim::Proposals::Proposal.where(component: current_component, id: proposal_ids).uniq
        end

        def target_component
          return current_component if clean_target_component_id == current_component.id

          @target_component ||= current_component.siblings.find_by(id: target_component_id)
        end

        def same_component?
          target_component == current_component
        end

        private

        def errors_set
          @errors_set ||= Set[]
        end

        def mergeable_to_same_component
          return true unless same_component?

          proposals.each do |proposal|
            errors_set << :voted if proposal.votes.any?
          end

          errors_set.each { |error| errors.add(:base, error) } if errors_set.any?
        end

        # Private: Returns the id of the target component.
        #
        # We receive this as ["id"] since it is from a select in a form.
        def clean_target_component_id
          target_component_id.first
        end

        def notify_missing_attachment_if_errored
          errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.present?
        end
      end
    end
  end
end
