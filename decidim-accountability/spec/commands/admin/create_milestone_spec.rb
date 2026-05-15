# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::CreateMilestone do
    subject { described_class.new(form) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:user) { create(:user, organization:) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
    let(:result) { create(:result, component: current_component) }

    let(:date) { "2017-8-23" }
    let(:title) { "Title" }
    let(:description) { "description" }

    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        decidim_accountability_result_id: result.id,
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
      let(:milestone) { Milestone.last }

      it "creates the milestone" do
        expect { subject.call }.to change(Milestone, :count).by(1)
      end

      it "sets the entry date" do
        subject.call
        expect(milestone.entry_date).to eq(Date.new(2017, 8, 23))
      end

      it "sets the title" do
        subject.call
        expect(translated(milestone.title)).to eq title
      end

      it "sets the description" do
        subject.call
        expect(translated(milestone.description)).to eq description
      end

      it "sets the result" do
        subject.call
        expect(milestone.result).to eq(result)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::Accountability::Milestone, user, {})
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("create")
        expect(action_log.version).to be_present
      end
    end
  end
end
