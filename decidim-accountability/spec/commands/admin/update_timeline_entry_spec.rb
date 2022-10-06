# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::UpdateTimelineEntry do
    subject { described_class.new(form, timeline_entry, user) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:user) { create :user, organization: }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:current_component) { create :accountability_component, participatory_space: participatory_process }
    let(:result) { create :result, component: current_component }

    let(:timeline_entry) { create :timeline_entry, result: }

    let(:date) { "2017-9-23" }
    let(:title) { "New title" }
    let(:description) { "new description" }

    let(:form) do
      double(
        invalid?: invalid,
        entry_date: date,
        title: { en: title },
        description: { en: description }
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "sets the date" do
        subject.call
        expect(timeline_entry.entry_date).to eq(Date.new(2017, 9, 23))
      end

      it "sets the description" do
        subject.call
        expect(translated(timeline_entry.description)).to eq description
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:update, Decidim::Accountability::TimelineEntry, user, {})
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("update")
        expect(action_log.version).to be_present
      end
    end
  end
end
