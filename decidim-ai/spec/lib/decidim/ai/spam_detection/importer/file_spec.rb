# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Importer::File do
  let(:service) { Decidim::Ai::SpamDetection::Service.new(registry: Decidim::Ai::SpamDetection.resource_registry) }

  before do
    allow(Decidim::Ai::SpamDetection).to receive(:resource_classifier).and_return(service)
  end

  def write_dataset(filename, content)
    path = Rails.application.root.join("tmp", filename)
    File.write(path, content)
    path
  end

  it "successfully loads the dataset" do
    expect(service).to receive(:train).exactly(4).times

    described_class.call(Decidim::Ai::Engine.root.join("spec/support/test.csv"), service)
  end

  context "when the dataset has an uppercase extension" do
    it "successfully loads the dataset" do
      expect(service).to receive(:train).twice

      described_class.call(
        write_dataset("uppercase_dataset.CSV", "spam;Hello world\nham;Nice to meet you\n"),
        service
      )
    end
  end

  context "when the dataset extension has no reader" do
    it "raises a clear error instead of failing with a NoMethodError" do
      file = write_dataset("unsupported_dataset.txt", "spam;Hello world\n")

      expect do
        described_class.call(file, service)
      end.to raise_error(NotImplementedError, "No reader implemented for file extension: txt")
    end
  end
end
