# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::BallotResultForm do
  subject { described_class.from_params(attributes) }

  let(:total_ballots_count) { valid_ballots_count.to_i + null_ballots_count.to_i + blank_ballots_count.to_i }
  let(:valid_ballots_count) { Faker::Number.number(digits: 1) }
  let(:blank_ballots_count) { Faker::Number.number(digits: 1) }
  let(:null_ballots_count) { Faker::Number.number(digits: 1) }

  let(:attributes) do
    {
      total_ballots_count:,
      valid_ballots_count:,
      blank_ballots_count:,
      null_ballots_count:
    }
  end

  it { is_expected.to be_valid }

  context "when valid_ballots_count is missing" do
    let(:valid_ballots_count) { nil }

    it { is_expected.to be_invalid }
  end

  context "when blank_ballots_count is missing" do
    let(:blank_ballots_count) { nil }

    it { is_expected.to be_invalid }
  end

  context "when null_ballots_count is missing" do
    let(:null_ballots_count) { nil }

    it { is_expected.to be_invalid }
  end

  context "when total_ballots_count does not match the breakdown" do
    let(:total_ballots_count) { 0 }

    it { is_expected.to be_invalid }
  end
end
