require "spec_helper"

describe Decidim::Admin::ActivateParticipatoryProcessStep do
  let(:process_step) { create :participatory_process_step }

  before do
    @success = nil
    @failure = nil
  end

  def success
    @success = true
  end

  def failure
    @failure = true
  end

  subject do
    described_class.call(process_step) do
      on(:ok) { success }
      on(:invalid) { failure }
    end
  end

  context "when the step is nil" do
    let(:process_step) { nil }

    it "is not valid" do
      subject
      expect(@failure).to eq true
    end
  end

  context "when the step is active" do
    let(:process_step) { create :participatory_process_step, :active }

    it "is not valid" do
      subject
      expect(@failure).to eq true
    end
  end

  context "when the step is not active" do
    let!(:active_step) do
      create :participatory_process_step, :active, participatory_process: process_step.participatory_process
    end

    it "is valid" do
      subject
      expect(@success).to eq true
    end

    it "activates it" do
      subject
      expect(process_step).to be_active
    end

    it "deactivates the process active steps" do
      subject
      active_step.reload
      expect(active_step).not_to be_active
    end
  end
end
