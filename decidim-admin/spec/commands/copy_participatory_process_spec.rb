# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::CopyParticipatoryProcess do
  let(:organization) { create :organization }
  let(:participatory_process_group) { create :participatory_process_group, organization: organization }
  let(:scope) { create :scope, organization: organization }
  let(:errors) { double.as_null_object }
  let!(:participatory_process) { create :participatory_process, :with_steps }
  let!(:feature) { create :feature, manifest_name: :dummy, participatory_process: participatory_process }
  let(:form) do
    instance_double(
      Decidim::Admin::ParticipatoryProcessCopyForm,
      invalid?: invalid,
      title: { en: "title" },
      slug: "copied_slug",
      copy_steps?: copy_steps,
      copy_categories?: copy_categories,
      copy_features?: copy_features
    )
  end
  let!(:category) do
    create(
      :category,
      participatory_process: participatory_process
    )
  end

  let(:invalid) { false }
  let(:copy_steps) { false }
  let(:copy_categories) { false }
  let(:copy_features) { false }

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

      old_participatory_process = Decidim::ParticipatoryProcess.first
      new_participatory_process = Decidim::ParticipatoryProcess.last

      expect(new_participatory_process.slug).to eq("copied_slug")
      expect(new_participatory_process.title["en"]).to eq("title")
      expect(new_participatory_process.organization).to eq(old_participatory_process.organization)
      expect(new_participatory_process.subtitle).to eq(old_participatory_process.subtitle)
      expect(new_participatory_process.description).to eq(old_participatory_process.description)
      expect(new_participatory_process.short_description).to eq(old_participatory_process.short_description)
      expect(new_participatory_process.promoted).to eq(old_participatory_process.promoted)
      expect(new_participatory_process.scope).to eq(old_participatory_process.scope)
      expect(new_participatory_process.developer_group).to eq(old_participatory_process.developer_group)
      expect(new_participatory_process.local_area).to eq(old_participatory_process.local_area)
      expect(new_participatory_process.target).to eq(old_participatory_process.target)
      expect(new_participatory_process.participatory_scope).to eq(old_participatory_process.participatory_scope)
      expect(new_participatory_process.meta_scope).to eq(old_participatory_process.meta_scope)
      expect(new_participatory_process.end_date).to eq(old_participatory_process.end_date)
      expect(new_participatory_process.participatory_process_group).to eq(old_participatory_process.participatory_process_group)
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

      old_participatory_process_step = Decidim::ParticipatoryProcessStep.first
      new_participatory_process_step = Decidim::ParticipatoryProcessStep.last

      expect(new_participatory_process_step.title).to eq(old_participatory_process_step.title)
      expect(new_participatory_process_step.description).to eq(old_participatory_process_step.description)
      expect(new_participatory_process_step.end_date).to eq(old_participatory_process_step.end_date)
      expect(new_participatory_process_step.start_date).to eq(old_participatory_process_step.start_date)
    end
  end

  context "when copy_steps exists" do
    let(:copy_categories) { true }

    it "duplicates a participatory process and the steps" do
      expect { subject.call }.to change { Decidim::Category.count }.by(1)
      expect(Decidim::Category.pluck(:decidim_participatory_process_id).uniq.count).to eq 2

      old_participatory_process_category = Decidim::Category.first
      new_participatory_process_category = Decidim::Category.last

      expect(new_participatory_process_category.name).to eq(old_participatory_process_category.name)
      expect(new_participatory_process_category.description).to eq(old_participatory_process_category.description)
      expect(new_participatory_process_category.parent).to eq(old_participatory_process_category.parent)
    end
  end

  context "when copy_steps exists" do
    let(:copy_features) { true }

    it "duplicates a participatory process and the steps" do
      dummy_hook = proc {}
      feature.manifest.on :copy, &dummy_hook
      expect(dummy_hook).to receive(:call).with(new_feature: an_instance_of(Decidim::Feature), old_feature: feature)

      expect { subject.call }.to change { Decidim::Feature.count }.by(1)

      last_participatory_process = Decidim::ParticipatoryProcess.last
      last_feature = Decidim::Feature.all.reorder(:id).last

      expect(last_feature.participatory_process).to eq(last_participatory_process)
      expect(last_feature.name).to eq(feature.name)
      expect(last_feature.settings).to eq(feature.settings)
    end
  end
end
