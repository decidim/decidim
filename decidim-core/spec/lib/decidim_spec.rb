# frozen_string_literal: true

require "spec_helper"

describe Decidim do
  it "has a version number" do
    expect(described_class.version).not_to be nil
  end

  describe ".seed!", processing_uploads_for: Decidim::AttachmentUploader do
    it "actually seeds" do
      expect { described_class.seed! }.not_to raise_error
    end

    it "loads seeds for every engine" do
      decidim_railties = [
        double(load_seed: nil, class: double(name: "Decidim::EngineA")),
        double(load_seed: nil, class: double(name: "Decidim::EngineB"))
      ]

      other_railties = [
        double(load_seed: nil, class: double(name: "Something::EngineA")),
        double(load_seed: nil, class: double(name: "Something::EngineB"))
      ]

      expect(decidim_railties).to all(receive(:load_seed))
      expect(other_railties).not_to include(receive(:load_seed))

      manifests = [double(name: "Feature A"), double(name: "Feature B")]
      expect(described_class).to receive(:participatory_space_manifests).and_return(manifests)

      expect(manifests).to all(receive(:seed!).once)

      application = double(railties: (decidim_railties + other_railties))
      expect(Rails).to receive(:application).and_return application

      described_class.seed!
    end
  end
end
