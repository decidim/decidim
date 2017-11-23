# frozen_string_literal: true

require "spec_helper"

describe FactoryBot, processing_uploads_for: Decidim::AttachmentUploader do
  it "has 100% valid factories" do
    expect { described_class.lint(traits: true) }.not_to raise_error
  end
end
