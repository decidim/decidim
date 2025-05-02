# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::CopyParticipatoryProcess do
    subject { described_class.new(form, participatory_process) }

    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, organization:) }
    let(:participatory_process_group) { create(:participatory_process_group, organization:, taxonomies: [taxonomy]) }
    let(:taxonomy) { create(:taxonomy, with_parent, organization:) }
    let(:errors) { double.as_null_object }
    let!(:participatory_process) { create(:participatory_process, :with_steps) }
    let!(:content_block) { create(:content_block, manifest_name: :hero, organization: participatory_process.organization, scope_name: :participatory_process_homepage, scoped_resource_id: participatory_process.id) }
    let!(:component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessCopyForm,
        invalid?: invalid,
        title: { en: "title" },
        slug: "copied-slug",
        copy_steps?: copy_steps,
        copy_components?: copy_components,
        copy_landing_page_blocks?: copy_landing_page_blocks,
        current_user:
      )
    end

    let(:invalid) { false }
    let(:copy_steps) { false }
    let(:copy_components) { false }
    let(:copy_landing_page_blocks) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "duplicates a participatory process" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcess, :count).by(1)

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
        expect(new_participatory_process.developer_group).to eq(old_participatory_process.developer_group)
        expect(new_participatory_process.local_area).to eq(old_participatory_process.local_area)
        expect(new_participatory_process.target).to eq(old_participatory_process.target)
        expect(new_participatory_process.participatory_scope).to eq(old_participatory_process.participatory_scope)
        expect(new_participatory_process.meta_scope).to eq(old_participatory_process.meta_scope)
        expect(new_participatory_process.end_date).to eq(old_participatory_process.end_date)
        expect(new_participatory_process.participatory_process_group).to eq(old_participatory_process.participatory_process_group)
        expect(new_participatory_process.private_space).to eq(old_participatory_process.private_space)
        expect(new_participatory_process.taxonomies).to eq(old_participatory_process.taxonomies)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("duplicate", Decidim::ParticipatoryProcess, current_user)
          .and_call_original
        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("duplicate")
        expect(action_log.version).to be_present
      end
    end

    context "when copy_steps exists" do
      let(:copy_steps) { true }

      it "duplicates a participatory process and the steps" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcessStep, :count).by(1)
        expect(Decidim::ParticipatoryProcessStep.distinct.pluck(:decidim_participatory_process_id).count).to eq 2

        old_participatory_process_step = Decidim::ParticipatoryProcessStep.first
        new_participatory_process_step = Decidim::ParticipatoryProcessStep.last

        expect(new_participatory_process_step.title).to eq(old_participatory_process_step.title)
        expect(new_participatory_process_step.description).to eq(old_participatory_process_step.description)
        expect(new_participatory_process_step.end_date).to eq(old_participatory_process_step.end_date)
        expect(new_participatory_process_step.start_date).to eq(old_participatory_process_step.start_date)
      end
    end

    context "when copy_components exists" do
      let(:copy_components) { true }

      it "duplicates a participatory process and the components" do
        dummy_hook = proc {}
        component.manifest.on :copy, &dummy_hook
        expect(dummy_hook).to receive(:call).with({ new_component: an_instance_of(Decidim::Component), old_component: component })

        expect { subject.call }.to change(Decidim::Component, :count).by(1)

        last_participatory_process = Decidim::ParticipatoryProcess.last
        last_component = Decidim::Component.all.reorder(:id).last

        expect(last_component.participatory_space).to eq(last_participatory_process)
        expect(last_component.name).to eq(component.name)
        expect(last_component.settings.attributes.except("dummy_global_translatable_text")).to eq(component.settings.attributes.except("dummy_global_translatable_text"))
        expect(last_component.settings.attributes["dummy_global_translatable_text"]).to include(component.settings.attributes["dummy_global_translatable_text"])
        expect(last_component.step_settings.keys).not_to eq(component.step_settings.keys)
        expect(last_component.step_settings.values).not_to eq(component.step_settings.values)
      end
    end

    context "when copy_landing_page_blocks exists" do
      let(:copy_landing_page_blocks) { true }
      let(:original_image) do
        Rack::Test::UploadedFile.new(
          Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
          "image/jpeg"
        )
      end

      before do
        content_block.images_container.background_image.purge
        content_block.images_container.background_image = original_image
        content_block.save
        content_block.reload
      end

      it "duplicates a participatory_process and the content_block with its attachments" do
        expect { subject.call }.to change(Decidim::ContentBlock, :count).by(1)

        old_block = Decidim::ContentBlock.unscoped.first
        new_block = Decidim::ContentBlock.unscoped.last
        last_process = Decidim::ParticipatoryProcess.last

        expect(new_block.scope_name).to eq(old_block.scope_name)
        expect(new_block.manifest_name).to eq(old_block.manifest_name)
        # published_at is set in content_block factory
        expect(new_block.published_at).not_to be_nil
        expect(new_block.scoped_resource_id).to eq(last_process.id)
        expect(new_block.attachments.length).to eq(1)
        expect(new_block.attachments.first.name).to eq("background_image")
        expect(new_block.images_container.attached_uploader(:background_image).url).not_to be_nil
      end
    end
  end
end
