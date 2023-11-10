# frozen_string_literal: true

module Decidim
  module Commands
    module ResourceHandler
      extend ActiveSupport::Concern

      included do
        protected

        attr_reader :form

        def resource_class = raise "#{self.class.name} needs to implement #{__method__}"

        # Hydrates the attributes from the form object that you need to update/create the resource.
        #
        # @return [Hash] a hash with the attributes.
        def attributes
          raise "You need to define the list of attributes to be fetched from form object fetch_form_attributes" unless defined?(:form_attributes)

          @attributes ||= form_attributes.index_with do |field|
            form.send(field)
          end
        end

        # Any extra params that you want to pass to the traceability service.
        #
        # @usage
        #  def extra_params = { "visibility" => "all"}
        #  def extra_params = { "visibility" => "public-only" }
        #  def extra_params = { "visibility" => "admin-only" }
        #
        # @return [Hash] a hash with the extra params.
        def extra_params = {}

        delegate :invalid?, to: :form

        class_attribute :form_attributes
        self.form_attributes = []

        def self.fetch_form_attributes(*fields)
          self.form_attributes += Array(fields)
        end
      end
    end
  end
end
