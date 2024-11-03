# frozen_string_literal: true

module Decidim
  module Debates
    # This class holds a Form to create/update debates from Decidim's public views.
    class DebateForm < Decidim::Form
      include Decidim::HasUploadValidations
      include Decidim::AttachmentAttributes
      include Decidim::TranslatableAttributes
      include Decidim::HasTaxonomyFormAttributes

      attribute :title, String
      attribute :description, String
      attribute :user_group_id, Integer
      attribute :attachment, AttachmentForm

      attachments_attribute :documents

      validates :title, presence: true
      validates :description, presence: true
      validate :editable_by_user
      validate :notify_missing_attachment_if_errored

      def map_model(debate)
        super
        # Debates can be translated in different languages from the admin but
        # the public form does not allow it. When a user creates a debate the
        # user locale is taken as the text locale.
        self.title = debate.title.values.first
        self.description = debate.description.values.first
        self.user_group_id = debate.decidim_user_group_id
        self.documents = debate.attachments
      end

      def participatory_space_manifest
        @participatory_space_manifest ||= current_component.participatory_space.manifest.name
      end

      def debate
        @debate ||= Debate.find_by(id:)
      end

      private

      def editable_by_user
        return unless debate.respond_to?(:editable_by?)

        errors.add(:debate, :invalid) unless debate.editable_by?(current_user)
      end

      # This method will add an error to the `add_documents` field only if there is
      # any error in any other field. This is needed because when the form has
      # an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.present?
      end
    end
  end
end
