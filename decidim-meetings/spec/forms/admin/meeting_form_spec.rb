# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingForm do
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
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:description) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:short_description) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:location) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:location_hints) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:services) do
      build_list(:service, 2)
    end
    let(:services_attributes) do
      services.map(&:attributes)
    end
    let(:address) { "Somewhere over the rainbow" }
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
    let(:type_of_meeting) { "in_person" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:registration_url) { "http://decidim.org" }
    let(:registration_type) { "on_this_platform" }
    let(:available_slots) { 0 }
    let(:iframe_embed_type) { "none" }
    let(:attributes) do
      {
        decidim_scope_id: scope_id,
        decidim_category_id: category_id,
        title_en: title[:en],
        description_en: description[:en],
        short_description_en: short_description[:en],
        location_en: location[:en],
        location_hints_en: location_hints[:en],
        address: address,
        start_time: start_time,
        end_time: end_time,
        private_meeting: private_meeting,
        transparent: transparent,
        services: services_attributes,
        registration_type: registration_type,
        available_slots: available_slots,
        registration_url: registration_url,
        type_of_meeting: type_of_meeting,
        online_meeting_url: online_meeting_url,
        iframe_embed_type: iframe_embed_type
      }
    end

    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it_behaves_like "a scopable resource"

    it { is_expected.to be_valid }

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when description is missing" do
      let(:description) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when location is missing and type of meeting is in_person" do
      let(:type_of_meeting) { "in_person" }
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

    describe "when the category does not exist" do
      let(:category_id) { category.id + 10 }

      it { is_expected.not_to be_valid }
    end

    it "validates address and store its coordinates" do
      expect(subject).to be_valid
      expect(subject.latitude).to eq(latitude)
      expect(subject.longitude).to eq(longitude)
    end

    it "properly maps services from model" do
      meeting = create(:meeting, :with_services, services: services)

      local_services = described_class.from_model(meeting).services
      expect(local_services).to all be_an(Admin::MeetingServiceForm)
      expect(local_services.map(&:title_en)).to eq(services.map { |s| s["title"]["en"] })
    end

    it "properly maps category id from model" do
      meeting = create(:meeting, component: current_component, category: category)

      expect(described_class.from_model(meeting).decidim_category_id).to eq(category_id)
    end

    describe "services_to_persist" do
      subject { form.services_to_persist }

      let(:services_attributes) do
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

    describe "when type of meeting is online and online meeting link is missing" do
      let(:type_of_meeting) { "online" }
      let(:online_meeting_url) { nil }

      it { is_expected.to be_valid }
    end

    describe "when type of meeting is online and online meeting link is not a URL" do
      let(:type_of_meeting) { "online" }
      let(:online_meeting_url) { "potato" }

      it { is_expected.not_to be_valid }
    end

    describe "when type of meeting is missing" do
      let(:type_of_meeting) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when registration type of meeting is missing" do
      let(:registration_type) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when registration url is missing and registration type of meeting is on different platform" do
      let(:registration_type) { "on_different_platform" }
      let(:registration_url) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when online meeting url is present and the meeting is embedded and the url can't be embedded" do
      let(:online_meeting_url) { "https://meet.jit.si/decidim" }
      let(:iframe_embed_type) { "embed_in_meeting_page" }

      it { is_expected.not_to be_valid }
    end
  end
end
