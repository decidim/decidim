# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :processing_uploads_for) do |example|
    uploader = example.metadata[:processing_uploads_for]

    uploader.enable_processing = true

    example.run

    uploader.enable_processing = false
  end
end
