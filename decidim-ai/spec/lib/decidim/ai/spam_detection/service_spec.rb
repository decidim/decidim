# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Service do
  subject { described_class.new(registry:) }

  let(:registry) { Decidim::Ai::SpamDetection.resource_registry }
  let(:base_strategy) { { name: :base, strategy: Decidim::Ai::SpamDetection::Strategy::Base } }
  let(:dummy_strategy) { { name: :dummy, strategy: Decidim::Ai::SpamDetection::Strategy::Base } }

  before do
    registry.clear
    registry.register_analyzer(**base_strategy)
    registry.register_analyzer(**dummy_strategy)
  end

  describe "train" do
    it "trains all the strategies" do
      expect(registry.for(:base)).to receive(:train).with(:spam, "text")
      expect(registry.for(:dummy)).to receive(:train).with(:spam, "text")

      subject.train(:spam, "text")
    end
  end

  describe "untrain" do
    it "untrains all the strategies" do
      expect(registry.for(:base)).to receive(:untrain).with(:spam, "text")
      expect(registry.for(:dummy)).to receive(:untrain).with(:spam, "text")

      subject.untrain(:spam, "text")
    end
  end

  describe "classify" do
    it "classifies using all strategies" do
      expect(registry.for(:base)).to receive(:classify).with("text")
      expect(registry.for(:dummy)).to receive(:classify).with("text")

      subject.classify("text")
    end
  end

  describe "classification_log" do
    it "returns the log of all strategies" do
      allow(registry.for(:base)).to receive(:log).and_return("base log")
      allow(registry.for(:dummy)).to receive(:log).and_return("dummy log")

      expect(subject.classification_log).to eq("base log\ndummy log")
    end
  end

  describe "score" do
    it "returns the average score of all strategies" do
      allow(registry.for(:base)).to receive(:score).and_return(1)
      allow(registry.for(:dummy)).to receive(:score).and_return(0)

      expect(subject.score).to eq(0.5)
    end
  end
end
