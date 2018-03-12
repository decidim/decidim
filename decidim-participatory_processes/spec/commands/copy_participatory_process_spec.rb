# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::CopyParticipatoryProcess do
    subject { described_class.new(form, participatory_process) }

    let(:organization) { create :organization }
    let(:participatory_process_group) { create :participatory_process_group, organization: organization }
    let(:scope) { create :scope, organization: organization }
    let(:errors) { double.as_null_object }
    let!(:participatory_process) { create :participatory_process, :with_steps }
    let!(:component) { create :component, manifest_name: :dummy, participatory_space: participatory_process }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessCopyForm,
        invalid?: invalid,
        title: { en: "title" },
        slug: "copied-slug",
        copy_steps?: copy_steps,
        copy_categories?: copy_categories,
        copy_components?: copy_components
      )
    end
    let!(:category) do
      create(
        :category,
        participatory_space: participatory_process
      )
    end

    let(:invalid) { false }
    let(:copy_steps) { false }
    let(:copy_categories) { false }
    let(:copy_components) { false }

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

        expect(new_participatory_process.slug).to eq("copied-slug")
        expect(new_participatory_process.title["en"]).to eq("title")
        expect(new_participatory_process).not_to be_published
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
        expect(Decidim::ParticipatoryProcessStep.distinct.pluck(:decidim_participatory_process_id).count).to eq 2

        old_participatory_process_step = Decidim::ParticipatoryProcessStep.first
        new_participatory_process_step = Decidim::ParticipatoryProcessStep.last

        expect(new_participatory_process_step.title).to eq(old_participatory_process_step.title)
        expect(new_participatory_process_step.description).to eq(old_participatory_process_step.description)
        expect(new_participatory_process_step.end_date).to eq(old_participatory_process_step.end_date)
        expect(new_participatory_process_step.start_date).to eq(old_participatory_process_step.start_date)
      end
    end

    context "when copy_categories exists" do
      let(:copy_categories) { true }

      it "duplicates a participatory process and the categories" do
        expect { subject.call }.to change { Decidim::Category.count }.by(1)
        expect(Decidim::Category.distinct.pluck(:decidim_participatory_space_id).count).to eq 2

        old_participatory_process_category = Decidim::Category.first
        new_participatory_process_category = Decidim::Category.last

        expect(new_participatory_process_category.name).to eq(old_participatory_process_category.name)
        expect(new_participatory_process_category.description).to eq(old_participatory_process_category.description)
        expect(new_participatory_process_category.parent).to eq(old_participatory_process_category.parent)
      end
    end

    context "when copy_components exists" do
      let(:copy_components) { true }

      it "duplicates a participatory process and the components" do
        dummy_hook = proc {}
        component.manifest.on :copy, &dummy_hook
        expect(dummy_hook).to receive(:call).with(new_component: an_instance_of(Decidim::Component), old_component: component)

        expect { subject.call }.to change { Decidim::Component.count }.by(1)

        last_participatory_process = Decidim::ParticipatoryProcess.last
        last_component = Decidim::Component.all.reorder(:id).last

        expect(last_component.participatory_space).to eq(last_participatory_process)
        expect(last_component.name).to eq(component.name)
        expect(last_component.settings.attributes).to eq(component.settings.attributes)
        expect(last_component.step_settings.keys).not_to eq(component.step_settings.keys)
        expect(last_component.step_settings.values).not_to eq(component.step_settings.values)
      end
    end
  end
end
