# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingCopyForm do
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
    let(:title) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:description) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:location) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:location_hints) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:services) do
      [
        { title: { en: "First service" }, description: { en: "First description" } },
        { title: { en: "Third service" }, description: { en: "Third description" } }
      ]
    end
    let(:address) { "Carrer Pic de Peguera 15, 17003 Girona" }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 2.days.from_now }
    let(:end_time) { 2.days.from_now + 4.hours }
    let(:organizer) { create :user, organization: organization }
    let(:organizer_id) { organizer.id }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:attributes) do
      {
        title_en: title[:en],
        description_en: description[:en],
        location_en: location[:en],
        location_hints_en: location_hints[:en],
        address: address,
        start_time: start_time,
        end_time: end_time,
        private_meeting: private_meeting,
        transparent: transparent,
        organizer_id: organizer_id,
        services: services
      }
    end

    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it { is_expected.to be_valid }

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when description is missing" do
      let(:description) { { en: nil } }

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

    it "validates address and store its coordinates" do
      expect(subject).to be_valid
      expect(subject.latitude).to eq(latitude)
      expect(subject.longitude).to eq(longitude)
    end

    it "properly maps services from model" do
      meeting = create(:meeting, services: services)

      services = described_class.from_model(meeting).services
      expect(services).to all be_an(Admin::MeetingServiceForm)
      expect(services.map(&:title_en)).to eq(services.map(&:title_en))
    end

    describe "services_to_persist" do
      subject { form.services_to_persist }

      let(:services) do
        [
          { title: { en: "First service" }, description: { en: "First description" } },
          { title: { en: "Second service" }, description: { en: "Second description" }, deleted: true },
          { title: { en: "Third service" }, description: { en: "Third description" } }
        ]
      end

      it "only returns non deleted services" do
        expect(subject.size).to eq(2)
        expect(subject.map(&:title_en)).to eq(["First service", "Third service"])
      end
    end

    describe "number_of_services" do
      subject { form.number_of_services }

      it { is_expected.to eq(services.size) }
    end
  end
end
