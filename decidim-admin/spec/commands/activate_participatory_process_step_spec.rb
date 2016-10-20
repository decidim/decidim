require "spec_helper"

describe Decidim::Admin::DeactivateParticipatoryProcessStep do
  let(:process_step) { create :participatory_process_step, :active }

  subject { described_class.new(process_step) }

  context "when the step is nil" do
    let(:process_step) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the step is inactive" do
    let(:process_step) { create :participatory_process_step }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the step is active" do
    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "deactivates it" do
      subject.call
      process_step.reload
      expect(process_step).not_to be_active
    end
  end
end
