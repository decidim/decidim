# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a Form to create/update answers from Decidim's admin panel.
      class AnswerForm < Decidim::Form
        include TranslatableAttributes
        include AttachmentAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :proposal_ids, Array[Integer]
        attribute :attachment, AttachmentForm
        attribute :weight, Integer, default: 0

        attachments_attribute :photos

        validates :title, translatable_presence: true
        validate :notify_missing_attachment_if_errored

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "related_proposals").pluck(:id)
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals)
                                .try(:resource_scope, current_component)
                                &.where(id: proposal_ids)
                                &.order(title: :asc)
        end

        def election
          @election ||= context[:election]
        end

        def question
          @question ||= context[:question]
        end

        private

        # This method will add an error to the `attachment` field only if there's
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:attachment, :needs_to_be_reattached) if errors.any? && attachment.present?
          errors.add(:add_photos, :needs_to_be_reattached) if errors.any? && add_photos.present?
        end
      end
    end
  end
end
