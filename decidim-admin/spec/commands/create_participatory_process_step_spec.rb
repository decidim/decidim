# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::CreateParticipatoryProcessStep do
  let(:participatory_process) { create :participatory_process }
  let(:form) do
    instance_double(
      Decidim::Admin::ParticipatoryProcessStepForm,
      title: { en: "title" },
      description: { en: "description" },
      start_date: Time.current,
      end_date: Time.current + 1.week,
      invalid?: invalid
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, participatory_process) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "creates a participatory process step" do
      expect { subject.call }.to change { Decidim::ParticipatoryProcessStep.count }.by(1)
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
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
