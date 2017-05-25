# frozen_string_literal: true

require "spec_helper"

describe Decidim do
  describe "seed!" do
    around do |example|
      Decidim::AttachmentUploader.enable_processing = true
      example.run
      Decidim::AttachmentUploader.enable_processing = false
    end

    it "actually seeds" do
      expect { described_class.seed! }.not_to raise_error
    end
  end
end
