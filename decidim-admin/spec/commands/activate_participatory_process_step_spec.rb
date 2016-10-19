require "spec_helper"

describe Decidim::Admin::DeactivateParticipatoryProcessStep do
  let(:process_step) { create :participatory_process_step, :active }

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

  context "when the step is inactive" do
    let(:process_step) { create :participatory_process_step }

    it "is not valid" do
      subject
      expect(@failure).to eq true
    end
  end

  context "when the step is active" do
    it "is valid" do
      subject
      expect(@success).to eq true
    end

    it "deactivates it" do
      subject
      process_step.reload
      expect(process_step).not_to be_active
    end
  end
end
