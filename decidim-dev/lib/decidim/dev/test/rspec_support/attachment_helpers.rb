# frozen_string_literal: true

# A collection of methods to help dealing with attachments.
module AttachmentHelpers
  # Gives the file size in an human readable form
  #
  # It is intended to be used to avoid the implementation details, so that the
  # attachment file size presentation can change more easily.
  def attachment_file_size(attachment)
    ActiveSupport::NumberHelper.number_to_human_size(attachment.file_size)
  end

  # Creates blob and returns its signed_id
  def upload_test_file(file, options = {})
    filename = options[:filename] || solve_filename(file)
    content_type = options[:content_type] || solve_content_type(file)

    blob = ActiveStorage::Blob.create_after_upload!(
      io: File.open(file),
      filename: filename,
      content_type: content_type
    )
    blob.signed_id
  end

  private

  def solve_filename(file)
    return file.original_filename if file.respond_to? :original_filename

    file.split("/").last
  end

  def solve_content_type(file)
    return file.content_type if file.respond_to? :content_type

    MIME::Types.type_for(file).first.content_type
  end
end

RSpec.configure do |config|
  config.include AttachmentHelpers
end
