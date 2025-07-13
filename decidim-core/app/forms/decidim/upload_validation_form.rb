# frozen_string_literal: true

module Decidim
  # A form object used to handle upload validations, this is used when user is
  # adding files to dropzone in upload modal.
  class UploadValidationForm < Decidim::Form
    include Decidim::HasUploadValidations

    attribute :resource_class, String
    # Property is named as attribute in upload modal and passthru validator, but
    # it cannot be named as attribute here.
    attribute :property, String
    attribute :blob, Decidim::Attributes::Blob
    attribute :form_class, String

    validates :resource_class, presence: true
    validates :property, presence: true
    validates :blob, presence: true
    validate :file_validators, if: ->(form) { form.resource_class.present? && form.property.present? && form.blob.present? }

    alias organization current_organization

    # This is a "trick" to provide the attachment context (i.e. admin or
    # participant) to the attachment records being validated. This is to show
    # the invalid content type / file extension errors with the correct file
    # extensions that may be shown in the help text next to the upload
    # drag'n'drop field.
    def attached_to
      @attached_to ||= AttachmentContextProxy.new(organization, attachment_context)
    end

    private

    def file_validators
      org = organization
      PassthruValidator.new(
        attributes: [property],
        to: resource_class.constantize,
        with: lambda { |record|
          validate_with.tap do |hash|
            hash.merge!(organization: record.try(:organization) || org) if !hash[:organization] && record.respond_to?(:organization=)
          end
        }
      ).validate_each(self, property.to_sym, blob)
    end

    def validate_with
      if form_object_class && form_object_class._validators[property.to_sym].is_a?(Array) && form_object_class._validators[property.to_sym].size.positive?
        passthru = form_object_class._validators[property.to_sym].find { |v| v.is_a?(PassthruValidator) }
        return passthru.options[:with] if passthru && passthru.options[:with].present?
      end
      {}
    end

    def form_object_class
      @form_object_class ||= begin
        form_class.constantize if form_class.present?
      rescue NameError
        nil
      end
    end

    # The attachment context (i.e. admin or participant) is determined using the
    # form class name and checking if it contains the `Admin` namespace in it.
    # And example use case is the attachment forms in the admin panel.
    def attachment_context
      return :participant unless form_object_class
      return :admin if form_object_class.name.include? "::Admin::"

      :participant
    end

    # This class provides ability to interpret the attachment context based on
    # the details available within the context of this class. Normally the
    # attachment context would be defined by the record to which the attachment
    # are added to, e.g. proposals (participant context) or participatory
    # processes (admin context). Unfortunately this information is not available
    # when the parameters are passed to the upload validation.
    class AttachmentContextProxy
      attr_reader :organization, :attachment_context

      delegate :id, :_read_attribute, :read_attribute, to: :organization

      def initialize(organization, attachment_context)
        @organization = organization
        @attachment_context = attachment_context
      end

      def self.primary_key
        :id
      end

      def self.composite_primary_key?
        false
      end

      def self.has_query_constraints?
        false
      end

      def self.polymorphic_name
        "Decidim::Organization"
      end
    end
  end
end
