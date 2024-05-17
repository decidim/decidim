# frozen_string_literal: true

module Decidim
  #
  # Decorator attachments of a component acting as an attachment collection
  #
  class ComponentAttachmentCollectionPresenter < SimpleDelegator
    include Decidim::TranslatableAttributes

    def attachments
      @attachments ||= begin
        resource_registry = Decidim.resource_registry.find(manifest_name)
        model_name = resource_registry&.model_class_name
        table_name = model_name&.safe_constantize&.table_name

        if [model_name, table_name].all?(&:present?)
          Decidim::Attachment.where(attached_to_type: model_name)
                             .joins("JOIN #{table_name} ON #{table_name}.id = decidim_attachments.attached_to_id")
                             .where(table_name => { decidim_component_id: __getobj__.id })
        else
          Decidim::Attachment.none
        end
      end
    end

    def documents
      @documents ||= attachments.with_attached_file.order(:weight).select(&:document?)
    end

    def unused?
      documents.blank?
    end

    def id
      "component-#{__getobj__.id}"
    end

    def name
      I18n.t("decidim.application.documents.component_documents", name: translated_attribute(__getobj__.name))
    end

    def description; end
  end
end
