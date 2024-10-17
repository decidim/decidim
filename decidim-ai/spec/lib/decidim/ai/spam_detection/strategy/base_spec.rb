# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Strategy::Base do
  subject { described_class.new({}) }

  it "trains" do
    expect { subject.train(:spam, "text") }.not_to raise_error
  end

  it "untrains" do
    expect { subject.untrain(:spam, "text") }.not_to raise_error
  end

  it "classifies" do
    expect { subject.classify("text") }.not_to raise_error
  end
end
