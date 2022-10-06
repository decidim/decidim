# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Census::InPersonForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:current_participatory_space) { create(:voting) }
  let(:document_number) { "123456789Y" }
  let(:document_type) { "DNI" }
  let(:day) { 14 }
  let(:month) { 8 }
  let(:year) { 1982 }

  let(:attributes) do
    {
      document_number:,
      document_type:,
      day:,
      month:,
      year:
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

  describe "when day is a string" do
    let(:day) { "a" }

    it { is_expected.to be_invalid }
  end

  describe "creates the birthday" do
    it { expect(subject.birthdate).to eql("19820814") }
  end

  describe "generate hash for data" do
    it { expect(subject.hashed_in_person_data).to eql("9f7afe479fef6eed220e090b48867aad58a83ba6ff37c641865a652bc39241fe") }
  end
end
