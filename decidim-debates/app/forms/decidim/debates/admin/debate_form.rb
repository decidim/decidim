# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This class holds a Form to create/update debates from Decidim's admin panel.
      class DebateForm < Decidim::Form
        mimic :debate

        include Decidim::HasUploadValidations
        include Decidim::AttachmentAttributes
        include Decidim::TranslatableAttributes
        include Decidim::HasTaxonomyFormAttributes

        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText
        translatable_attribute :instructions, Decidim::Attributes::RichText
        translatable_attribute :information_updates, Decidim::Attributes::RichText
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :finite, Boolean, default: true
        attribute :comments_layout, String, default: "single_column"
        attribute :comments_enabled, Boolean, default: true
        attribute :attachment, AttachmentForm

        attachments_attribute :documents

        validates :title, :description, translatable_presence: true
        validates :title, :description, translated_etiquette: true
        validates :instructions, translatable_presence: true
        validates :start_time, presence: { if: :validate_start_time? }, date: { before: :end_time, allow_blank: true, if: :validate_start_time? }
        validates :end_time, presence: { if: :validate_end_time? }, date: { after: :start_time, allow_blank: true, if: :validate_end_time? }
        validates :comments_layout, presence: true, inclusion: { in: %w(single_column two_columns) }
        validate :comments_layout_change, if: -> { debate&.comments_count&.positive? }

        validate :notify_missing_attachment_if_errored

        def map_model(model)
          self.finite = model.start_time.present? && model.end_time.present?
          presenter = DebatePresenter.new(model)

          self.title = presenter.title(all_locales: title.is_a?(Hash))
          self.description = presenter.description(all_locales: description.is_a?(Hash))
          self.comments_layout = model.comments_layout || "single_column"
          self.documents = model.attachments
        end

        def participatory_space_manifest
          @participatory_space_manifest ||= current_component.participatory_space.manifest.name
        end

        private

        def debate
          @debate ||= context[:debate]
        end

        def validate_end_time?
          finite && start_time.present?
        end

        def validate_start_time?
          end_time.present?
        end

        def comments_layout_change
          errors.add(:comments_layout, I18n.t("form.errors.comments_layout_locked", scope: "decidim.debates.admin.debates")) if debate.comments_layout != comments_layout
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
end
