# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Importer::File do
  let!(:path) { Gem.loaded_specs["decidim-ai"].full_gem_path }
  let!(:file) { "spec/support/test.csv" }

  it "successfully loads the dataset" do
    instance = Decidim::Ai::SpamDetection::Service.new
    allow(Decidim::Ai).to receive(:spam_detection_instance).and_return(instance)
    expect(instance).to receive(:train).exactly(4).times

    described_class.call("#{path}/#{file}")
  end
end
