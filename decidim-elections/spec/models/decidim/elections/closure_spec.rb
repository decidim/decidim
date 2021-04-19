# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Closure, type: :model do
  subject(:closure) { build(:closure, :with_polling_station_results) }

  it { is_expected.to be_valid }

  it "has an associated election" do
    expect(closure.election).to be_a(Decidim::Elections::Election)
  end

  it "has an associated polling_station" do
    expect(closure.polling_station).to be_a(Decidim::Votings::PollingStation)
  end

  it "has an associated polling_officer" do
    expect(closure.polling_officer).to be_a(Decidim::Votings::PollingOfficer)
  end
end
