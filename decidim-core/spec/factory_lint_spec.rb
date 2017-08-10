# frozen_string_literal: true

require "spec_helper"

describe "Lint factories", processing_uploads_for: Decidim::AttachmentUploader do
  it "has 100% valid factories" do
    expect { FactoryGirl.lint(traits: true) }.not_to raise_error
  end
end
