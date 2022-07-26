# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe AgendaItem do
      subject { agenda_item }

      let(:agenda_item) { create(:agenda_item) }

      it { is_expected.to be_valid }

      it "has an association of agenda item as children" do
        subject.agenda_item_children << create(:agenda_item)
        subject.agenda_item_children << create(:agenda_item)
        expect(subject.agenda_item_children.count).to eq(2)
      end

      it "has an association of agenda item as parent" do
        subject.parent = create(:agenda_item)
        expect(subject.parent).to be_present
      end

      context "without an agenda" do
        let(:agenda_item) { build :agenda_item, agenda: nil }

        it { is_expected.not_to be_valid }
      end

      it "has an associated agenda" do
        expect(agenda_item.agenda).to be_a(Decidim::Meetings::Agenda)
        expect(Decidim::Meetings::AgendaItem.last.agenda).to be_a(Decidim::Meetings::Agenda)
      end

      describe ".first_class" do
        let(:parent) { create(:agenda_item) }
        let(:child) { create(:agenda_item, parent:) }

        it "returns agenda items without a parent" do
          expect(described_class.first_class).to eq([parent])
        end
      end

      describe ".agenda_item_children" do
        let(:parent) { create(:agenda_item) }
        let(:child) { create(:agenda_item, parent:) }

        it "returns agenda items that have a parent" do
          expect(described_class.agenda_item_children).to eq([child])
        end
      end

      describe "#parent?" do
        it "returns false if the agenda item have a parent" do
          subject.parent = create(:agenda_item)
          expect(subject).not_to be_parent
        end

        it "returns true if the agenda item doesn't have a parent" do
          subject.parent = nil
          expect(subject).to be_parent
        end
      end
    end
  end
end
