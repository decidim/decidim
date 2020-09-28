# frozen_string_literal: true

module Decidim
  module MultipleAttachmentsMethods
    private

    def build_attachments
      @files = []
      @form.add_files.each do |file|
        @files << Attachment.new(
          title: file.original_filename,
          attached_to: @attached_to || files_attached_to,
          file: file
        )
      end
    end

    def attachments_invalid?
      @files.each do |file|
        if file.invalid? && file.errors.has_key?(:file)
          @form.errors.add(:add_files, file.errors[:file])
          return true
        end
      end
      false
    end

    def create_attachments
      @files.map! do |file|
        file.attached_to = files_attached_to
        file.save!
        @form.files << file.id.to_s
      end
    end

    def file_cleanup!
      files_attached_to.documents.each do |file|
        file.destroy! if @form.files.exclude? file.id.to_s
      end

      files_attached_to.reload
      files_attached_to.instance_variable_set(:@files, nil)
    end

    def process_attachments?
      @form.add_files.any?
    end

    def files_attached_to
      return @attached_to if @attached_to.present?
      return form.current_organization if form.respond_to?(:current_organization)

      form.current_component.organization if form.respond_to?(:current_component)
    end
  end
end
