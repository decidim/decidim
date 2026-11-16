# frozen_string_literal: true

require "tempfile"
require "spec_helper"

describe Decidim::Ai::SpamDetection::Importer::File do
  let(:service) { Decidim::Ai::SpamDetection::Service.new(registry: Decidim::Ai::SpamDetection.resource_registry) }

  before do
    allow(Decidim::Ai::SpamDetection).to receive(:resource_classifier).and_return(service)
  end

  def with_dataset(filename, content)
    Tempfile.create(["spam_dataset", File.extname(filename)]) do |file|
      file.write(content)
      file.flush
      yield file.path
    end
  end

  it "successfully loads the dataset" do
    expect(service).to receive(:train).exactly(4).times

    described_class.call(Decidim::Ai::Engine.root.join("spec/support/test.csv"), service)
  end

  context "when the dataset has an uppercase extension" do
    it "successfully loads the dataset" do
      expect(service).to receive(:train).twice

      with_dataset("uppercase_dataset.CSV", "spam;Hello world\nham;Nice to meet you\n") do |path|
        described_class.call(path, service)
      end
    end
  end

  context "when the dataset extension has no reader" do
    it "raises a clear error instead of failing with a NoMethodError" do
      with_dataset("unsupported_dataset.txt", "spam;Hello world\n") do |path|
        expect do
          described_class.call(path, service)
        end.to raise_error(NotImplementedError, "No reader implemented for file extension: txt")
      end
    end
  end
end
