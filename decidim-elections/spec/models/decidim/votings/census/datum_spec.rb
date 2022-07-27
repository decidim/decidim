# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Census::Datum do
  subject { datum }

  let(:dataset) { create(:dataset) }

  let(:datum) { build(:datum, dataset:) }

  it { is_expected.to be_valid }

  it "has an associated dataset" do
    expect(datum.dataset).to be_a(Decidim::Votings::Census::Dataset)
  end

  describe "uniqueness" do
    context "with hashed_in_person_data" do
      let!(:another_datum) do
        create :datum,
               dataset:,
               hashed_in_person_data: datum.hashed_in_person_data
      end

      it { is_expected.not_to be_valid }
    end

    context "with hashed_check_data" do
      let!(:another_datum) do
        create :datum,
               dataset:,
               hashed_check_data: datum.hashed_check_data
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe "presence" do
    context "without full_name" do
      let(:datum) { build(:datum, full_name: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without full_address" do
      let(:datum) { build(:datum, full_address: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without postal_code" do
      let(:datum) { build(:datum, postal_code: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without hashed_in_person_data" do
      let(:datum) { build(:datum, hashed_in_person_data: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without hashed_check_data" do
      let(:datum) { build(:datum, hashed_check_data: nil) }

      it { is_expected.not_to be_valid }
    end
  end
end
