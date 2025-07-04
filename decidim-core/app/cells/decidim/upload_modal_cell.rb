# frozen_string_literal: true

module Decidim
  # This cell creates the necessary elements for dynamic uploads.
  class UploadModalCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include ERB::Util

    alias form model

    def show
      return unless resource_name

      render
    end

    private

    def button_id
      prefix = form.object_name.present? ? "#{form.object_name}_" : ""

      "#{prefix.gsub(/[\[\]]/, "_").gsub(/__+/, "_")}#{attribute}_button"
    end

    def button_class
      options[:button_class] || ""
    end

    def label
      form.send(:custom_label, attribute, options[:label], { required: required?, for: nil })
    end

    def button_label
      return button_edit_label if attachments.count.positive?

      options[:button_label]
    end

    def button_edit_label
      options[:button_edit_label] || options[:button_label]
    end

    def max_file_size
      options[:max_file_size]
    end

    def max_file_size_mb
      return unless max_file_size

      (((max_file_size / 1024 / 1024) * 100) / 100).round
    end

    def resource_class
      options[:resource_class].to_s
    end

    def resource_name
      options[:resource_name]
    end

    def attribute
      options[:attribute]
    end

    def multiple
      options[:multiple] || false
    end

    def required?
      options[:required] == true
    end

    # By default FoundationRailsHelper adds form errors next to input, but since input is in the modal
    # and modal is hidden by default, we need to add an additional validation field to the form.
    # This should only be necessary when file is required by the form.
    def input_validation_field
      object_name = form.object.present? ? "#{form.object.model_name.param_key}[#{add_attribute}_validation]" : "#{add_attribute}_validation"
      input = check_box_tag object_name, 1, attachments.present?, class: "reset-defaults", hidden: true, label: false, required: required?
      message = form.send(:abide_error_element, add_attribute) + form.send(:error_and_help_text, add_attribute)
      input + message
    end

    def explanation
      i18n_options = {
        scope: options[:help_i18n_scope].presence || "decidim.forms.upload_help",
        attribute: attribute_translation
      }

      I18n.t("explanation", **i18n_options)
    end

    def attribute_translation
      I18n.t(attribute, scope: [:activemodel, :attributes, resource_class.constantize.model_name.param_key].join("."))
    rescue NameError
      I18n.t(attribute, scope: "activemodel.attributes")
    end

    def add_attribute
      return "add_#{attribute}" if form.object.respond_to? "add_#{attribute}"

      attribute
    end

    def has_title?
      options[:titled] == true
    end

    def modal_only?
      options[:modal_only] == true
    end

    def with_title
      "with-title" if has_title?
    end

    def help_messages
      Array(options[:help])
    end

    def attachments
      @attachments = begin
        attachments = options[:attachments] || form.object.send(attribute)
        attachments = Array(attachments).compact_blank
        attachments.map { |attachment| attachment.is_a?(String) ? ActiveStorage::Blob.find_signed(attachment) : attachment }
      end
    end

    def id_for(attachment)
      return attachment.id if attachment.respond_to? :id

      rand(1..10_000)
    end

    def title_for(attachment)
      if has_title?
        decidim_html_escape(decidim_sanitize(translated_attribute(attachment.title)))
      else
        decidim_html_escape(decidim_sanitize(determine_filename(attachment)))
      end
    end

    def truncated_file_name_for(attachment, max_length = 31)
      filename = determine_filename(attachment)
      return decidim_html_escape(filename).html_safe if filename.length <= max_length

      name = File.basename(filename, File.extname(filename))
      decidim_html_escape(name.truncate(max_length, omission: "...#{name.last((max_length / 2) - 3)}#{File.extname(filename)}")).html_safe
    end

    def file_name_for(attachment)
      decidim_html_escape(determine_filename(attachment)).html_safe
    end

    def determine_filename(attachment)
      return attachment.filename.to_s if attachment.is_a? ActiveStorage::Blob
      return blob(attachment).filename.to_s if blob(attachment).present?
      return attachment.original_filename.to_s.presence || attachment.path.split("/").last if attachment.is_a? ActionDispatch::Http::UploadedFile

      attachment.url.split("/").last
    end

    def file_attachment_path(attachment)
      return unless attachment
      return Rails.application.routes.url_helpers.rails_blob_url(attachment, only_path: true) if attachment.is_a? ActiveStorage::Blob

      if attachment.try(:attached?)
        attachment_path = Rails.application.routes.url_helpers&.rails_blob_url(blob(attachment), only_path: true)
        return attachment_path if attachment_path.present?
      end

      uploader_default_image_path(attribute)
    end

    def uploader_default_image_path(attribute)
      uploader = Decidim::FileValidatorHumanizer.new(form.object, attribute).uploader
      return if uploader.blank?
      return unless uploader.is_a?(Decidim::ImageUploader)

      uploader.try(:default_url)
    end

    def blob(attachment)
      return attachment if attachment.is_a? ActiveStorage::Blob
      return ActiveStorage::Blob.find_signed(attachment) if attachment.is_a? String
      return attachment.file.blob if attachment.is_a? Decidim::Attachment
      return attachment.blob if attachment.respond_to? :blob
    end

    def direct_upload_url
      Rails.application.class.routes.url_helpers.rails_direct_uploads_path
    end

    def upload_validations_url
      Decidim::Core::Engine.routes.url_helpers.upload_validations_path
    end

    def form_object_class
      form.object.class.to_s
    end

    def modal_id
      @modal_id ||= options[:modal_id] || "upload_#{SecureRandom.uuid}"
    end

    def current_organization
      controller.current_organization
    end
  end
end
