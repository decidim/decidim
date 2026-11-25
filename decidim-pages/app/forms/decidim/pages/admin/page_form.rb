# frozen_string_literal: true

module Decidim
  module Pages
    module Admin
      # This class holds a Form to update pages from Decidim's admin panel.
      class PageForm < Decidim::Form
        include TranslatableAttributes
        include Decidim::AttachmentAttributes

        translatable_attribute :body, Decidim::Attributes::RichText

        attribute :attachment, AttachmentForm
        attachments_attribute :attachments

        validate :notify_missing_attachment_if_errored

        def map_model(model)
          super
          return unless model.respond_to?(:attachments)

          self.attachments = model.attachments.ids
          self.add_attachments = model.attachments.map { |att| { id: att.id, title: att.title } }
        end

        def notify_missing_attachment_if_errored
          errors.add(:add_attachments, :needs_to_be_reattached) if errors.any? && add_attachments.present?
        end
      end
    end
  end
end
