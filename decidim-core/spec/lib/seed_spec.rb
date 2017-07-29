# frozen_string_literal: true

require "spec_helper"

describe Decidim do
  describe "seed!", processing_uploads_for: Decidim::AttachmentUploader do
    let!(:participatory_space) { create(:participatory_process) }

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

      decidim_railties.each { |r| expect(r).to receive(:load_seed) }
      other_railties.each { |r| expect(r).not_to receive(:load_seed) }

      manifests = [double(name: "Feature A"), double(name: "Feature B")]
      expect(Decidim).to receive(:feature_manifests).and_return(manifests)

      manifests.each do |manifest|
        expect(manifest).to receive(:seed!).with(participatory_space).once
      end

      application = double(railties: (decidim_railties + other_railties))
      expect(Rails).to receive(:application).and_return application

      Decidim.seed!
    end
  end
end
