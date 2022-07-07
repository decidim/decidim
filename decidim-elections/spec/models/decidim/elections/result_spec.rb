# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Result do
  subject(:result) { build(:election_result) }

  it { is_expected.to be_valid }

  it "has an associated question" do
    expect(result.question).to be_a(Decidim::Elections::Question)
  end

  it "has an associated answer" do
    expect(result.answer).to be_a(Decidim::Elections::Answer)
  end

  context "when the result comes from the bulletin board" do
    it "has an associated bulletin board closure" do
      expect(result.closurable).to be_a(Decidim::Elections::BulletinBoardClosure)
    end
  end
end
