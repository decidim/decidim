# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component:,
        current_participatory_space: participatory_process
      }
    end
    let(:participatory_process) { create :participatory_process, organization: }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:title) { Faker::Lorem.sentence(word_count: 1) }
    let(:description) { Faker::Lorem.sentence(word_count: 3) }
    let(:short_description) { Faker::Lorem.sentence(word_count: 1) }
    let(:location) { Faker::Lorem.sentence(word_count: 3) }
    let(:location_hints) { Faker::Lorem.sentence(word_count: 3) }
    let(:address) { "Some address" }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 2.days.from_now }
    let(:end_time) { 2.days.from_now + 4.hours }
    let(:parent_scope) { create(:scope, organization:) }
    let(:scope) { create(:subscope, parent: parent_scope) }
    let(:scope_id) { scope.id }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:category_id) { category.id }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:type_of_meeting) { "in_person" }
    let(:registration_type) { "on_this_platform" }
    let(:available_slots) { 0 }
    let(:registration_url) { "http://decidim.org" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:iframe_embed_type) { "none" }
    let(:registration_terms) { Faker::Lorem.sentence(word_count: 3) }
    let(:attributes) do
      {
        decidim_scope_id: scope_id,
        decidim_category_id: category_id,
        title:,
        description:,
        short_description:,
        location:,
        location_hints:,
        address:,
        start_time:,
        end_time:,
        private_meeting:,
        transparent:,
        type_of_meeting:,
        online_meeting_url:,
        registration_type:,
        available_slots:,
        registration_terms:,
        registrations_enabled: true,
        registration_url:,
        iframe_embed_type:
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

    describe "when location is missing and type of meeting is in_person" do
      let(:type_of_meeting) { "in_person" }
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
      meeting = create(:meeting, component: current_component, category:)

      expect(described_class.from_model(meeting).decidim_category_id).to eq(category_id)
    end

    describe "when online meeting link is missing and type of meeting is online" do
      let(:type_of_meeting) { "online" }
      let(:online_meeting_url) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when type of meeting is missing" do
      let(:type_of_meeting) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when registration url is missing and registration type of meeting is on different platform" do
      let(:registration_type) { "on_different_platform" }
      let(:registration_url) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when registration type of meeting is missing" do
      let(:registration_type) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when registration type is on this platform" do
      let(:registration_type) { "on_this_platform" }

      describe "available slots are missing" do
        let(:available_slots) { nil }

        it { is_expected.not_to be_valid }
      end

      describe "registration terms are missing" do
        let(:registration_terms) { nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe "when online meeting url is present and the meeting is embedded and the url can't be embedded" do
      let(:online_meeting_url) { "https://example.org/decidim" }
      let(:iframe_embed_type) { "embed_in_meeting_page" }

      it { is_expected.not_to be_valid }
    end
  end
end
