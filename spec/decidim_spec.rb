# frozen_string_literal: true

require_relative "spec_helper"

describe Decidim do
  it "has a version number" do
    expect(Decidim.version).not_to be nil
  end

  describe "#seed!" do
    it "loads seeds of every engine" do
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
        expect(manifest).to receive(:seed!).once
      end

      application = double(railties: (decidim_railties + other_railties))
      expect(Rails).to receive(:application).and_return application

      Decidim.seed!
    end
  end
end
