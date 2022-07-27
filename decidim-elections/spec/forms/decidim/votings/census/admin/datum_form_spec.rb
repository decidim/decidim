# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Census::Admin::DatumForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:dataset) { create(:dataset) }
  let(:user) { create(:user, :admin, organization: dataset.voting.organization) }
  let(:document_number) { "123456789Y" }
  let(:document_type) { "DNI" }
  let(:birthdate) { "20010414" }
  let(:full_name) { "Jane Doe" }
  let(:full_address) { "Nowhere street 1" }
  let(:postal_code) { "12345" }
  let(:mobile_phone_number) { "123456789" }
  let(:email) { "example@test.org" }
  let(:ballot_style_code) { "BS1" }

  let(:attributes) do
    {
      document_number:,
      document_type:,
      birthdate:,
      full_name:,
      full_address:,
      postal_code:,
      mobile_phone_number:,
      ballot_style_code:,
      email:
    }
  end

  let(:context) do
    {
      current_user: user,
      dataset:
    }
  end

  it { is_expected.to be_valid }

  describe "when document_number is missing" do
    let(:document_number) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when document_type is missing" do
    let(:document_type) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when birthdate is missing" do
    let(:birthdate) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when full_name is missing" do
    let(:full_name) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when full_address is missing" do
    let(:full_address) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when postal_code is missing" do
    let(:postal_code) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when mobile_phone_number is missing" do
    let(:mobile_phone_number) { nil }

    it { is_expected.to be_valid }
  end

  describe "when email is missing" do
    let(:email) { nil }

    it { is_expected.to be_valid }
  end

  describe "when document_type is not in the accepted values" do
    let(:document_type) { "invalid type" }

    it { is_expected.to be_invalid }
  end

  describe "when ballot style code is missing" do
    let(:ballot_style_code) { nil }

    it { is_expected.to be_valid }
  end
end
