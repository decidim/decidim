# frozen_string_literal: true

module Decidim
  module MultipleAttachmentsMethods
    private

    def build_attachments
      @attachments = []
      @form.add_attachments.compact_blank.each do |attachment|
        if attachment.is_a?(Hash) && attachment.has_key?(:id)
          update_attachment_title_for(attachment)
          next
        end

        @attachments << Attachment.new(
          title: title_for(attachment),
          attached_to: @attached_to || attachments_attached_to,
          file: signed_id_for(attachment),
          content_type: content_type_for(attachment)
        )
      end
    end

    def update_attachment_title_for(attachment)
      Decidim::Attachment.find(attachment[:id]).update(title: title_for(attachment))
    end

    def attachments_invalid?
      @attachments.each do |attachment|
        next if attachment.valid? || !attachment.errors.has_key?(:file)

        attachment.errors[:file].each do |error|
          @form.errors.add(:add_attachments, error)
        end

        return true
      end

      false
    end

    def create_attachments(first_weight: 0)
      weight = first_weight
      # Add the weights first to the old attachments
      attachment_ids = keep_ids
      Decidim::Attachment.where(id: attachment_ids).each do |attachment|
        attachment.update!(weight:)
        weight += 1
      end
      @attachments.map! do |attachment|
        attachment.weight = weight
        attachment.attached_to = attachments_attached_to
        attachment.save!
        weight += 1
        @form.attachments << attachment
      end
    end

    def attachment_cleanup!(include_all_attachments: false)
      attachments = include_all_attachments ? attachments_attached_to.attachments.with_attached_file : attachments_attached_to.attachments

      attachments.each do |attachment|
        attachment.destroy! unless keep_ids.include?(attachment.id)
      end

      attachments_attached_to.reload
      attachments_attached_to.instance_variable_set(:@attachments, nil)
      attachments_attached_to.instance_variable_set(:@photos, nil)
    end

    def process_attachments?
      @form.add_attachments.any?
    end

    def attachments_attached_to
      return @attached_to if @attached_to.present?
      return form.current_organization if form.respond_to?(:current_organization)

      form.current_component.organization if form.respond_to?(:current_component)
    end

    def signed_id_for(attachment)
      return attachment[:file] if attachment.is_a?(Hash)

      attachment
    end

    def title_for(attachment)
      return { I18n.locale => attachment[:title] } if attachment.is_a?(Hash) && attachment.has_key?(:title)

      { I18n.locale => "" }
    end

    def content_type_for(attachment)
      return attachment.content_type if attachment.instance_of?(ActionDispatch::Http::UploadedFile)

      blob(signed_id_for(attachment)).content_type
    end

    def blob(signed_id)
      ActiveStorage::Blob.find_signed(signed_id)
    end

    def keep_ids
      attachments_array = Array(@form.attachments)
      attachments_array.map do |doc|
        case doc
        when Decidim::Attachment
          doc.id
        when Integer
          doc
        when String
          doc.match?(/\A\d+\z/) ? doc.to_i : nil
        when Hash
          (doc[:id] || doc["id"]).to_i
        end
      end.compact
    end
  end
end
