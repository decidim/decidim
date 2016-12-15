# frozen_literal_string: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingForm do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:context) do
    {
      current_organization: organization,
      current_user: current_user,
      current_feature: current_feature
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_process: participatory_process }
  let(:current_user) { instance_double(Decidim::User).as_null_object }
  let(:title) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:description) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:short_description) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:location_hints) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:address) { Faker::Lorem.sentence(3) }
  let(:start_date) { 2.days.from_now }
  let(:end_date) { 2.days.from_now + 4.hours }
  let(:attributes) do
    {
      title_en: title[:en],
      description_en: description[:en],
      short_description_en: short_description[:en],
      location_hints_en: location_hints[:en],
      address: address,
      start_date: start_date,
      end_date: end_date
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

  describe "when address is missing" do
    let(:address) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when start_date is missing" do
    let(:start_date) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when end_date is missing" do
    let(:end_date) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when current_user is missing" do
    let(:current_user) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when current_feature is missing" do
    let(:current_feature) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when start_date is after end_date" do
    let(:start_date) { end_date + 3.days }

    it { is_expected.not_to be_valid }
  end

  describe "when end_date is before start_date" do
    let(:end_date) { start_date - 3.days }

    it { is_expected.not_to be_valid }
  end

  describe "when start_date is equal to start_date" do
    let(:start_date) { end_date }

    it { is_expected.not_to be_valid }
  end
end
