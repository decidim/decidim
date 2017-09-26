# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::TimelineEntryForm do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:context) do
    {
      current_organization: organization,
      current_feature: current_feature
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }
  let(:result) { create :result, feature: current_feature }

  let(:entry_date) { "12/3/2017" }
  let(:description) do
    Decidim::Faker::Localized.sentence(3)
  end

  let(:attributes) do
    {
      decidim_accountability_result_id: result.id,
      entry_date: entry_date,
      description_en: description[:en]
    }
  end

  subject { described_class.from_params(attributes).with_context(context) }

  it { is_expected.to be_valid }

  describe "when entry date is missing" do
    let(:entry_date) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { { en: nil } }

    it { is_expected.not_to be_valid }
  end
end
