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
      attribute :attachment, AttachmentForm

      attachments_attribute :documents

      validates :title, :description, presence: true
      validates :title, :description, etiquette: true
      validate :editable_by_user

      def map_model(debate)
        super
        # Debates can be translated in different languages from the admin but
        # the public form does not allow it. When a user creates a debate the
        # user locale is taken as the text locale.
        self.title = debate.title.values.first
        self.description = debate.description.values.first
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
    end
  end
end
