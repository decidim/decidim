# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingAgendaForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component:,
        current_participatory_space: participatory_process,
        meeting:
      }
    end
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "meetings") }
    let(:meeting) { create(:meeting, component: current_component) }

    let(:title) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:visible) { true }
    let(:agenda_items) do
      [
        {
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5),
          duration: 1.hour,
          position: 0
        },
        {
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5),
          duration: 1.hour,
          position: 1
        }
      ]
    end

    let(:attributes) do
      {
        title:,
        visible:,
        agenda_items:
      }
    end

    before do
      allow(meeting).to receive(:meeting_duration).and_return(6.hours)
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when a agenda_item is not valid" do
      let(:agenda_items) do
        [
          {
            title: nil,
            description: Decidim::Faker::Localized.sentence(word_count: 5),
            duration: 1.hour,
            position: 0
          }
        ]
      end

      it { is_expected.not_to be_valid }
    end

    describe "when agenda duration is greater than meeting duration" do
      let(:agenda_items) do
        [
          {
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.sentence(word_count: 5),
            duration: meeting.meeting_duration + 1.hour,
            position: 0
          }
        ]
      end

      it { is_expected.not_to be_valid }
    end

    describe "when agenda items duration is greater than their parent" do
      let(:agenda_items) do
        [
          {
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.sentence(word_count: 5),
            duration: 45.minutes,
            position: 0,
            agenda_item_children: [
              {
                title: Decidim::Faker::Localized.sentence(word_count: 2),
                description: Decidim::Faker::Localized.sentence(word_count: 5),
                duration: 50.minutes,
                position: 0
              }
            ]
          }
        ]
      end

      it { is_expected.not_to be_valid }
    end

    describe "when deleting an item with longer than meeting duration and adding a new one with shorter duration" do
      let(:agenda) { create(:agenda, meeting:) }
      let(:existing_item) { create(:agenda_item, agenda:, duration: meeting.meeting_duration + 2.hours) }
      let(:agenda_items) do
        [
          {
            id: existing_item.id,
            title: existing_item.title,
            description: existing_item.description,
            deleted: true,
            duration: existing_item.duration,
            position: 0
          },
          {
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.sentence(word_count: 5),
            deleted: false,
            duration: meeting.meeting_duration - 3.hours,
            position: 1
          }
        ]
      end

      it { is_expected.to be_valid }
    end

    describe "when adding an item with less than meeting duration" do
      let(:agenda) { create(:agenda, meeting:) }
      let(:existing_item) { create(:agenda_item, agenda:, duration: meeting.meeting_duration - 3.hours) }
      let(:agenda_items) do
        [
          {
            id: existing_item.id,
            title: existing_item.title,
            description: existing_item.description,
            deleted: false,
            duration: existing_item.duration,
            position: 0
          }
        ]
      end

      it { is_expected.to be_valid }
    end

    describe "when deleting shorter than meeting items and keeping longer than meeting items" do
      let(:agenda) { create(:agenda, meeting:) }
      let(:existing_item1) { create(:agenda_item, agenda:, duration: meeting.meeting_duration - 3.hours) }
      let(:existing_item2) { create(:agenda_item, agenda:, duration: meeting.meeting_duration + 2.hours) }
      let(:existing_item3) { create(:agenda_item, agenda:, duration: meeting.meeting_duration - 2.hours) }

      let(:agenda_items) do
        [
          {
            id: existing_item1.id,
            title: existing_item1.title,
            description: existing_item1.description,
            deleted: true,
            duration: existing_item1.duration,
            position: 0
          },
          {
            id: existing_item2.id,
            title: existing_item2.title,
            description: existing_item2.description,
            deleted: false,
            duration: existing_item2.duration,
            position: 1
          },
          {
            id: existing_item3.id,
            title: existing_item3.title,
            description: existing_item3.description,
            deleted: true,
            duration: existing_item3.duration,
            position: 0
          }
        ]
      end

      it { is_expected.not_to be_valid }
    end
  end
end
