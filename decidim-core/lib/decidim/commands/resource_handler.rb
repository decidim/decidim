# frozen_string_literal: true

module Decidim
  module Commands
    module ResourceHandler
      extend ActiveSupport::Concern

      included do
        include ::Decidim::AttachmentAttributesMethods

        protected

        attr_reader :form

        def resource_class = raise "#{self.class.name} needs to implement #{__method__}"

        # Hydrates the attributes from the form object that you need to update/create the resource.
        #
        # @return [Hash] a hash with the attributes.
        def attributes
          @attributes ||= {}.merge(form_attribute_values).merge(file_attribute_values)
        end

        def form_attribute_values
          raise "You need to define the list of attributes to be fetched from form object fetch_form_attributes" if form_attributes.empty?

          form_attributes.index_with do |field|
            form.send(field)
          end
        end

        def file_attribute_values
          return {} if file_attributes.empty?

          attachment_attributes(*file_attributes)
        end

        def has_file_attributes?
          file_attributes.any?
        end

        def add_file_attribute_errors!
          file_attributes.each do |field|
            form.errors.add(field, resource.errors.messages_for(field)&.first) if resource.errors.include? field
          end
        end

        # Any extra params that you want to pass to the traceability service.
        #
        # @usage
        #  def extra_params = { "visibility" => "all"}
        #  def extra_params = { "visibility" => "public-only" }
        #  def extra_params = { "visibility" => "admin-only" }
        #  def extra_params
        #    {
        #      resource: {
        #        title: resource.title
        #      },
        #      participatory_space: {
        #        title: resource.participatory_space.title
        #      }
        #    }
        #  end
        # @return [Hash] a hash with the extra params.
        def extra_params = {}

        delegate :invalid?, to: :form

        class_attribute :form_attributes
        self.form_attributes = []

        class_attribute :file_attributes
        self.file_attributes = []

        def self.fetch_form_attributes(*fields)
          self.form_attributes += Array(fields)
        end

        def self.fetch_file_attributes(*fields)
          self.file_attributes += Array(fields)
        end
      end
    end
  end
end
