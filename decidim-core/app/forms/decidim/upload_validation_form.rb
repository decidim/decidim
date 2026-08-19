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
      target_class = resource_class.constantize

      if target_class == Decidim::ContentBlockAttachment && target_class.validators_on(property.to_sym).none?
        validate_content_block_image
      else
        validate_passthru(target_class, org)
      end
    end

    # Content block image uploads (e.g. hero background_image) go through
    # ContentBlockAttachment which requires a content_block association to
    # resolve the uploader. The dummy record created by PassthruValidator has
    # no content_block, so attached_uploader returns nil and validators bail
    # out silently. Instead, validate the blob directly against the
    # RecordImageUploader allowlist used by all content block image uploaders.
    def validate_content_block_image
      uploader = Decidim::RecordImageUploader.new(nil, :file)
      allowed_types = uploader.content_type_allowlist
      allowed_extensions = uploader.extension_allowlist

      content_type = blob.content_type.to_s
      extension = blob.filename.to_s.split(".").last&.downcase

      unless allowed_types.include?(content_type)
        message = format(
          "The file type %{content_type} is not valid. Allowed types: %{allowed}",
          content_type:, allowed: allowed_types.join(", ")
        )
        errors.add(property.to_sym, message)
      end

      return if extension.blank?
      return if allowed_extensions.include?(extension)

      message = format(
        "The file extension .%{ext} is not valid. Allowed extensions: %{allowed}",
        ext: extension, allowed: allowed_extensions.join(", ")
      )
      errors.add(property.to_sym, message)
    end

    def validate_passthru(target_class, org)
      PassthruValidator.new(
        attributes: [property],
        to: target_class,
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
        form_class.presence&.constantize
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
