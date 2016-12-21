# frozen_literal_string: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingForm do
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
  let(:location) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:location_hints) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:address) { Faker::Lorem.sentence(3) }
  let(:start_time) { 2.days.from_now }
  let(:end_time) { 2.days.from_now + 4.hours }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_process: participatory_process }
  let(:attributes) do
    {
      decidim_scope_id: scope.id,
      decidim_category_id: category.id,
      title_en: title[:en],
      description_en: description[:en],
      short_description_en: short_description[:en],
      location_en: location[:en],
      location_hints_en: location_hints[:en],
      address: address,
      start_time: start_time,
      end_time: end_time
    }
  end

  subject { described_class.from_params(attributes, context).with_context(current_feature: current_feature) }

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

  describe "when location is missing" do
    let(:location) { { en: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when address is missing" do
    let(:address) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when start_time is missing" do
    let(:start_time) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when end_time is missing" do
    let(:end_time) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when current_feature is missing" do
    let(:current_feature) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when start_time is after end_time" do
    let(:start_time) { end_time + 3.days }

    it { is_expected.not_to be_valid }
  end

  describe "when end_time is before start_time" do
    let(:end_time) { start_time - 3.days }

    it { is_expected.not_to be_valid }
  end

  describe "when start_time is equal to start_time" do
    let(:start_time) { end_time }

    it { is_expected.not_to be_valid }
  end
end
