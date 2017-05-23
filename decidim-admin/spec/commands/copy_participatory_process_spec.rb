# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::CopyParticipatoryProcess do
  let(:organization) { create :organization }
  let(:participatory_process_group) { create :participatory_process_group, organization: organization }
  let(:scope) { create :scope, organization: organization }
  let(:errors) { double.as_null_object }
  let!(:participatory_process) { create :participatory_process, :with_steps }
  let(:form) do
    instance_double(
      Decidim::Admin::ParticipatoryProcessCopyForm,
      invalid?: invalid,
      title: { en: "title" },
      slug: "copied_slug",
      copy_steps?: copy_steps
    )
  end
  let(:invalid) { false }
  let(:copy_steps) { false }

  subject { described_class.new(form, participatory_process) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "duplicates a participatory process" do
      expect { subject.call }.to change { Decidim::ParticipatoryProcess.count }.by(1)
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end
  end

  context "when copy_steps exists" do
    let(:copy_steps) { true }

    it "duplicates a participatory process and the steps" do
      expect { subject.call }.to change { Decidim::ParticipatoryProcessStep.count }.by(1)
      expect(Decidim::ParticipatoryProcessStep.pluck(:decidim_participatory_process_id).uniq.count).to eq 2
    end
  end
end
