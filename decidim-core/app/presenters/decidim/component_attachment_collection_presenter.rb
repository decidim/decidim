# frozen_string_literal: true

module Decidim
  #
  # Decorator attachments of a component acting as an attachment collection
  #
  class ComponentAttachmentCollectionPresenter < SimpleDelegator
    include Decidim::TranslatableAttributes

    def initialize(resource, opts = {})
      super(resource)

      @include_component_name = opts[:include_component_name]
    end

    def attachments
      @attachments ||= if [resource_model_name, resource_table_name].all?(&:present?)
                         base_query = Decidim::Attachment.joins(resource_join.join_sources)
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
      base_name = I18n.t(manifest_name, scope: "decidim.application.documents.component_documents")

      return base_name unless @include_component_name

      "#{base_name} - #{translated_attribute(__getobj__.name)}"
    end

    def description; end

    private

    def resource_join
      resource_table = Arel::Table.new(resource_table_name)
      attachments_table = Decidim::Attachment.arel_table
      attachments_table.join(resource_table).on(
        resource_table[:id].eq(attachments_table[:attached_to_id]),
        attachments_table[:attached_to_type].eq(resource_model_name)
      )
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
  end
end
