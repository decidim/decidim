# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::TemplateTextsForm do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:context) do
    {
      current_organization: organization,
      current_feature: current_feature
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_space: participatory_process, manifest_name: "accountability" }

  let(:intro) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:categories_label) do
    Decidim::Faker::Localized.word
  end
  let(:subcategories_label) do
    Decidim::Faker::Localized.word
  end
  let(:heading_parent_level_results) do
    Decidim::Faker::Localized.word
  end
  let(:heading_leaf_level_results) do
    Decidim::Faker::Localized.word
  end

  let(:attributes) do
    {
      intro: intro,
      categories_label: categories_label,
      subcategories_label: subcategories_label,
      heading_parent_level_results: heading_parent_level_results,
      heading_leaf_level_results: heading_leaf_level_results
    }
  end

  subject { described_class.from_params(attributes).with_context(context) }

  it { is_expected.to be_valid }

  describe "when intro is missing" do
    let(:intro) { nil }

    it { is_expected.to be_valid }
  end

  describe "when categories_label is missing" do
    let(:categories_label) { { en: nil } }

    it { is_expected.to be_valid }
  end
end
