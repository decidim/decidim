# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Importer::File do
  it "successfully loads the dataset" do
    instance = Decidim::Ai::SpamDetection::Service.new(registry: Decidim::Ai::SpamDetection.resource_registry)
    allow(Decidim::Ai::SpamDetection).to receive(:resource_classifier).and_return(instance)
    expect(instance).to receive(:train).exactly(4).times

    described_class.call(Decidim::Ai::Engine.root.join("spec/support/test.csv"), Decidim::Ai::SpamDetection.resource_classifier)
  end
end
