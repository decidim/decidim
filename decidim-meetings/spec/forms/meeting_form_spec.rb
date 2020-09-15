# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component: current_component,
        current_participatory_space: participatory_process
      }
    end
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:title) { Faker::Lorem.sentence(1) }
    let(:description) { Faker::Lorem.sentence(3) }
    let(:short_description) { Faker::Lorem.sentence(1) }
    let(:location) { Faker::Lorem.sentence(3) }
    let(:location_hints) { Faker::Lorem.sentence(3) }
    let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 2.days.from_now }
    let(:end_time) { 2.days.from_now + 4.hours }
    let(:parent_scope) { create(:scope, organization: organization) }
    let(:scope) { create(:subscope, parent: parent_scope) }
    let(:scope_id) { scope.id }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:category_id) { category.id }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:attributes) do
      {
        decidim_scope_id: scope_id,
        decidim_category_id: category_id,
        title: title,
        description: description,
        short_description: short_description,
        location: location,
        location_hints: location_hints,
        address: address,
        start_time: start_time,
        end_time: end_time,
        private_meeting: private_meeting,
        transparent: transparent
      }
    end

    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it_behaves_like "a scopable resource"

    it { is_expected.to be_valid }

    describe "when title is missing" do
      let(:title) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when description is missing" do
      let(:description) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when location is missing" do
      let(:location) { nil }

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

    it "validates address and store its coordinates" do
      expect(subject).to be_valid
      expect(subject.latitude).to eq(latitude)
      expect(subject.longitude).to eq(longitude)
    end

    it "properly maps category id from model" do
      meeting = create(:meeting, component: current_component, category: category)

      expect(described_class.from_model(meeting).decidim_category_id).to eq(category_id)
    end
  end
end
