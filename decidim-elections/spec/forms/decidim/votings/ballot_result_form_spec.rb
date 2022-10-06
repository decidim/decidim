# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::BallotResultForm do
  subject { described_class.from_params(attributes) }

  let(:valid_ballots_count) { Faker::Number.number(digits: 1) }
  let(:blank_ballots_count) { Faker::Number.number(digits: 1) }
  let(:null_ballots_count) { Faker::Number.number(digits: 1) }

  let(:attributes) do
    {
      valid_ballots_count:,
      blank_ballots_count:,
      null_ballots_count:
    }
  end

  it { is_expected.to be_valid }

  describe "when valid_ballots_count is missing" do
    let(:valid_ballots_count) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when blank_ballots_count is missing" do
    let(:blank_ballots_count) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when null_ballots_count is missing" do
    let(:null_ballots_count) { nil }

    it { is_expected.to be_invalid }
  end
end
