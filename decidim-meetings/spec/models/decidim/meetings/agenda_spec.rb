# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Agenda do
      subject { agenda }

      let(:agenda) { create(:agenda) }

      it { is_expected.to be_valid }

      it "has an association of agenda items" do
        subject.agenda_items << create(:agenda_item)
        subject.agenda_items << create(:agenda_item)
        expect(subject.agenda_items.count).to eq(2)
      end

      context "without a meeting" do
        let(:agenda) { build :agenda, meeting: nil }

        it { is_expected.not_to be_valid }
      end

      it "has an associated meeting" do
        expect(agenda.meeting).to be_a(Decidim::Meetings::Meeting)
      end
    end
  end
end
