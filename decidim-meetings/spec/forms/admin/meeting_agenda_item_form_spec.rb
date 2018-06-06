# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingAgendaItemsForm do
    subject(:form) { described_class.from_params(attributes).with_context(current_organization: organization) }

    let(:organization) { create(:organization, available_locales: [:en]) }

    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:meeting) { create :meeting, component: current_component }

    let(:title) { Decidim::Faker::Localized.sentence(3) }
    let(:duration) { rand(5..100) }
    let(:description) { Decidim::Faker::Localized.sentence(5) }
    let(:position) { 0 }
    let(:parent_id) { nil }
    let(:deleted) { false }

    let(:agenda_item_children) do
      [
        {
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          duration: 12,
          position: 0
        },
        {
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          duration: 24,
          position: 1
        }
      ]
    end

    let(:attributes) do
      {
        title: title,
        description: description,
        duration: duration,
        parent_id: parent_id,
        deleted: deleted,
        position: position,
        agenda_item_children: agenda_item_children
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when position is not greater than 0" do
      let(:position) { -2 }

      it { is_expected.not_to be_valid }
    end

    describe "when duration is not greater than 0" do
      let(:duration) { -2 }

      it { is_expected.not_to be_valid }
    end
  end
end
