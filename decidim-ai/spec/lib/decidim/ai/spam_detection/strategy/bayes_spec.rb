# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Strategy::Bayes do
  subject { described_class.new({}) }

  let(:backend) { ClassifierReborn::Bayes.new :spam, :ham }

  describe "train" do
    it "calls backend.train" do
      expect(subject.send(:backend)).to receive(:train).with(:spam, "text")

      subject.train(:spam, "text")
    end
  end

  describe "untrain" do
    it "calls backend.untrain" do
      subject.train(:spam, "text")
      subject.train(:ham, "foo bar")

      expect(subject.send(:backend)).to receive(:untrain).with(:spam, "text")

      subject.untrain(:spam, "text")
    end
  end

  describe "classify" do
    it "calls backend.classify" do
      expect(subject.send(:backend)).to receive(:classify_with_score).with("text")

      subject.classify("text")
    end
  end

  describe "log" do
    it "returns a log" do
      expect(subject.log).to be_nil
    end

    context "when category is spam" do
      it "returns a log" do
        allow(subject.send(:backend)).to receive(:classify_with_score).with("text").and_return(["spam", -12.6997])
        subject.classify("text")
        expect(subject.log).to eq("The Classification engine marked this as spam")
      end
    end
  end

  describe "score" do
    it "returns a score" do
      expect(subject.score).to eq(0)
    end

    it "returns 0 when is ham" do
      allow(subject.send(:backend)).to receive(:classify_with_score).with("text").and_return(["ham", -12.6997])
      subject.classify("text")
      expect(subject.score).to eq(0)
    end

    it "returns 1 when is spam" do
      subject.train(:spam, "text")
      subject.train(:ham, "foo bar")

      allow(subject.send(:backend)).to receive(:classify_with_score).with("text").and_return(["spam", -12.6997])
      subject.classify("text")
      expect(subject.score).to eq(1)
    end
  end
end
