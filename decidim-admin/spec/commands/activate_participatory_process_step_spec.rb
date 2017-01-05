require "spec_helper"

describe Decidim::Admin::ActivateParticipatoryProcessStep do
  let(:active_step) { create :participatory_process_step }
  let(:participatory_process) { active_step.participatory_process }
  let(:process_step) { create :participatory_process_step, participatory_process: participatory_process }

  subject { described_class.new(process_step) }

  context "when the step is nil" do
    let(:process_step) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the step is active" do
    subject { described_class.new(active_step) }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the step is not active" do

    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "activates it" do
      subject.call
      expect(process_step).to be_active
    end

    it "deactivates the process active steps" do
      subject.call
      active_step.reload
      expect(active_step).not_to be_active
    end
  end
end
