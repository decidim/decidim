# frozen_literal_string: true

require "spec_helper"

describe Decidim::Results::Admin::ResultForm do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:context) do
    {
      current_organization: organization,
      current_feature: current_feature
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_process: participatory_process }
  let(:title) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:description) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:short_description) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:scope) { create :scope, organization: organization }
  let(:scope_id) { scope.id }
  let(:category) { create :category, participatory_process: participatory_process }
  let(:category_id) { category.id }
  let(:attributes) do
    {
      decidim_scope_id: scope_id,
      decidim_category_id: category_id,
      title_en: title[:en],
      description_en: description[:en],
      short_description_en: short_description[:en]
    }
  end

  subject { described_class.from_params(attributes).with_context(context) }

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { en: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { { en: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when short_description is missing" do
    let(:short_description) { { en: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when current_feature is missing" do
    let(:current_feature) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when the scope does not exist" do
    let(:scope_id) { scope.id + 10 }

    it { is_expected.not_to be_valid }
  end

  describe "when the category does not exist" do
    let(:category_id) { category.id + 10 }

    it { is_expected.not_to be_valid }
  end
end
