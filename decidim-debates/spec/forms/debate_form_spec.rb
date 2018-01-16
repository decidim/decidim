# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::DebateForm do
  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_organization: organization,
      current_feature: current_feature
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_space: participatory_process }
  let(:title) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:description) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:instructions) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:start_time) { 2.days.from_now }
  let(:end_time) { 2.days.from_now + 4.hours }
  let(:category) { create :category, participatory_space: participatory_process }
  let(:category_id) { category.id }
  let(:attributes) do
    {
      decidim_category_id: category_id,
      title: title,
      description: description,
      instructions: instructions,
      start_time: start_time,
      end_time: end_time
    }
  end

  subject { described_class.from_params(attributes).with_context(context) }

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when instructions is missing" do
    let(:instructions) { { ca: nil, es: nil } }

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

  describe "when the category does not exist" do
    let(:category_id) { category.id + 10 }

    it { is_expected.not_to be_valid }
  end
end
