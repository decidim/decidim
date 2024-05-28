# frozen_string_literal: true

module Decidim
  #
  # Decorator attachments of a component acting as an attachment collection
  #
  class ComponentAttachmentCollectionPresenter < SimpleDelegator
    include Decidim::TranslatableAttributes

    def attachments
      @attachments ||= if [resource_model_name, resource_table_name].all?(&:present?)
                         base_query = Decidim::Attachment.where(attached_to_type: resource_model_name)
                                                         .joins("JOIN #{resource_table_name} ON #{resource_table_name}.id = decidim_attachments.attached_to_id")
                                                         .where(resource_table_name => { decidim_component_id: __getobj__.id })
                         if resource_model&.include?(Decidim::Publicable)
                           base_query.where.not(resource_table_name => { published_at: nil })
                         else
                           base_query
                         end
                       else
                         Decidim::Attachment.none
                       end
    end

    def resource_model_name
      @resource_model_name ||= Decidim.resource_registry.find(manifest_name)&.model_class_name
    end

    def resource_model
      @resource_model ||= resource_model_name&.safe_constantize
    end

    def resource_table_name
      @resource_table_name ||= resource_model&.table_name
    end

    def documents
      @documents ||= attachments.with_attached_file.order(:weight).select(&:document?)
    end

    def documents_visible_for(user)
      return documents unless resource_model.respond_to?(:visible_for)

      attachments.merge(resource_model.visible_for(user)).with_attached_file.order(:weight).select(&:document?)
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
