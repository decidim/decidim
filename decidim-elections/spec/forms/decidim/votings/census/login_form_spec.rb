# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Census::LoginForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:current_participatory_space) { create(:voting) }
  let(:document_number) { "123456789Y" }
  let(:document_type) { "DNI" }
  let(:day) { 14 }
  let(:month) { 8 }
  let(:year) { 1982 }
  let(:postal_code) { "12345" }
  let(:access_code) { "123" }

  let(:attributes) do
    {
      document_number:,
      document_type:,
      day:,
      month:,
      year:,
      postal_code:,
      access_code:
    }
  end

  let(:context) do
    {
      current_participatory_space:
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

  describe "when day is missing" do
    let(:day) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when postal_code is missing" do
    let(:postal_code) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when access_code is missing" do
    let(:access_code) { nil }

    it { is_expected.to be_invalid }
  end

  describe "creates the birthday" do
    it { expect(subject.birthdate).to eql("19820814") }
  end

  describe "generate hash for data" do
    it { expect(subject.hashed_online_data).to eql("8782f5d25e944a227ca3d9a444919ff0ea479151b6733127ff04bf9cc7ce3240") }
  end
end
