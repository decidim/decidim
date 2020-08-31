# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::ElectionForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_organization: organization,
      current_component: current_component
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :elections_component, participatory_space: participatory_process }
  let(:title) { Decidim::Faker::Localized.sentence(3) }
  let(:subtitle) { Decidim::Faker::Localized.sentence(3) }
  let(:description) { Decidim::Faker::Localized.sentence(3) }
  let(:start_time) { 1.day.from_now }
  let(:end_time) { 3.days.from_now }
  let(:attributes) do
    {
      title: title,
      subtitle: subtitle,
      description: description,
      start_time: start_time,
      end_time: end_time
    }
  end

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when subtitle is missing" do
    let(:subtitle) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { { ca: nil, es: nil } }

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

  describe "when start_time is after end_time" do
    let(:start_time) { end_time + 3.days }

    it { is_expected.not_to be_valid }
  end

  describe "when start_time is equal to start_time" do
    let(:start_time) { end_time }

    it { is_expected.not_to be_valid }
  end
end
