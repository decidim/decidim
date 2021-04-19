# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Result do
  subject(:result) { build(:election_result) }

  it { is_expected.to be_valid }

  it "has an associated closure" do
    expect(result.closure).to be_a(Decidim::Elections::Closure)
  end

  it "has an associated question" do
    expect(result.question).to be_a(Decidim::Elections::Question)
  end

  it "has an associated answer" do
    expect(result.answer).to be_a(Decidim::Elections::Answer)
  end
end
