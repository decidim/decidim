# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::CreateParticipatoryProcessStep do
    subject { described_class.new(form, participatory_process) }

    let(:user) { create :user, :admin }
    let(:participatory_process) { create :participatory_process }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessStepForm,
        current_user: user,
        title: { en: "title" },
        description: { en: "description" },
        start_date: Date.current,
        end_date: Date.current + 1.week,
        invalid?: invalid
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "creates a participatory process step" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcessStep, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::ParticipatoryProcessStep, user, hash_including(:title, :description, :start_date, :end_date, :participatory_process, :active))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "when the process has no active steps" do
        it "creates the step as active" do
          subject.call
          expect(Decidim::ParticipatoryProcessStep.last).to be_active
        end
      end

      context "when the process has active steps" do
        before do
          create(:participatory_process_step, participatory_process: participatory_process, active: true)
        end

        it "creates the step as active" do
          subject.call
          expect(Decidim::ParticipatoryProcessStep.last).not_to be_active
        end
      end
    end
  end
end
