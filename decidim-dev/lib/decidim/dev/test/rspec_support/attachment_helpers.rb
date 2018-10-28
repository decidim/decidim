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
end

RSpec.configure do |config|
  config.include AttachmentHelpers
end
