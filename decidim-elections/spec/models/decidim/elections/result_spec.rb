# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Result do
  subject(:result) { build(:election_result, :with_polling_station) }

  it { is_expected.to be_valid }

  it "has an associated election" do
    expect(result.election).to be_a(Decidim::Elections::Election)
  end

  it "has an associated question" do
    expect(result.question).to be_a(Decidim::Elections::Question)
  end

  it "has an associated answer" do
    expect(result.answer).to be_a(Decidim::Elections::Answer)
  end

  it "has an associated polling_station" do
    expect(result.polling_station).to be_a(Decidim::Votings::PollingStation)
  end
end
