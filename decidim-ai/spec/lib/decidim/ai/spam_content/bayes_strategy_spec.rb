# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamContent::BayesStrategy do
  subject { described_class.new({}) }

  let(:backend) { ClassifierReborn::Bayes.new :spam, :ham }

  describe "train" do
    it "calls backend.train" do
      expect(subject.send(:backend)).to receive(:train).with("spam", "text")

      subject.train("spam", "text")
    end
  end

  describe "untrain" do
    it "calls backend.untrain" do
      expect(subject.send(:backend)).to receive(:untrain).with("spam", "text")

      subject.untrain("spam", "text")
    end
  end

  describe "classify" do
    it "calls backend.classify" do
      expect(subject.send(:backend)).to receive(:classify).with("text")

      subject.classify("text")
    end
  end

  describe "log" do
    it "returns a log" do
      expect(subject.log).to eq("The Classification engine marked this as ...")
    end
  end
end
