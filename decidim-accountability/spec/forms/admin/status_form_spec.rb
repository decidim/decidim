# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::StatusForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component:
      }
    end
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "accountability") }
    let(:name) do
      Decidim::Faker::Localized.word
    end
    let(:description) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:key) { "status_key" }
    let(:progress) { 60 }

    let(:attributes) do
      {
        key:,
        name_en: name[:en],
        description_en: description[:en],
        progress:
      }
    end

    it { is_expected.to be_valid }

    describe "when key is missing" do
      let(:key) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when name is missing" do
      let(:name) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when progress is negative" do
      let(:progress) { -12 }

      it { is_expected.not_to be_valid }
    end

    describe "when progress is greater than 100" do
      let(:progress) { 999 }

      it { is_expected.not_to be_valid }
    end

    describe "when progress is between 0 and 100" do
      let(:progress) { (0..100).to_a.sample }

      it { is_expected.to be_valid }
    end

    describe "when progress is empty" do
      let(:progress) { nil }

      it { is_expected.to be_valid }
    end
  end
end
