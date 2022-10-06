# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::TimelineEntryForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component:
      }
    end
    let(:participatory_process) { create :participatory_process, organization: }
    let(:current_component) { create :accountability_component, participatory_space: participatory_process }
    let(:result) { create :result, component: current_component }

    let(:entry_date) { "12/3/2017" }
    let(:title) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:description) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end

    let(:attributes) do
      {
        decidim_accountability_result_id: result.id,
        entry_date:,
        title_en: title[:en],
        description_en: description[:en]
      }
    end

    it { is_expected.to be_valid }

    describe "when entry date is missing" do
      let(:entry_date) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when description is missing" do
      let(:description) { { en: nil } }

      it { is_expected.to be_valid }
    end
  end
end
