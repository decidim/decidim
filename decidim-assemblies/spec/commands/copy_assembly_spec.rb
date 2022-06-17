# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CopyAssembly do
    subject { described_class.new(form, assembly, user) }

    let(:organization) { create :organization }
    let(:user) { create :user, organization: }
    let(:scope) { create :scope, organization: }
    let(:errors) { double.as_null_object }
    let!(:assembly) { create :assembly }
    let!(:component) { create :component, manifest_name: :dummy, participatory_space: assembly }
    let(:form) do
      instance_double(
        Admin::AssemblyCopyForm,
        invalid?: invalid,
        title: { en: "title" },
        slug: "copied-slug",
        copy_categories?: copy_categories,
        copy_components?: copy_components
      )
    end
    let!(:category) do
      create(
        :category,
        participatory_space: assembly
      )
    end

    let(:invalid) { false }
    let(:copy_categories) { false }
    let(:copy_components) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "duplicates an assembly" do
        expect { subject.call }.to change { Decidim::Assembly.count }.by(1)

        old_assembly = Decidim::Assembly.first
        new_assembly = Decidim::Assembly.last

        expect(new_assembly.slug).to eq("copied-slug")
        expect(new_assembly.title["en"]).to eq("title")
        expect(new_assembly).not_to be_published
        expect(new_assembly.organization).to eq(old_assembly.organization)
        expect(new_assembly.subtitle).to eq(old_assembly.subtitle)
        expect(new_assembly.description).to eq(old_assembly.description)
        expect(new_assembly.short_description).to eq(old_assembly.short_description)
        expect(new_assembly.promoted).to eq(old_assembly.promoted)
        expect(new_assembly.scope).to eq(old_assembly.scope)
        expect(new_assembly.developer_group).to eq(old_assembly.developer_group)
        expect(new_assembly.local_area).to eq(old_assembly.local_area)
        expect(new_assembly.target).to eq(old_assembly.target)
        expect(new_assembly.participatory_scope).to eq(old_assembly.participatory_scope)
        expect(new_assembly.meta_scope).to eq(old_assembly.meta_scope)
        expect(new_assembly.announcement).to eq(old_assembly.announcement)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("duplicate", Decidim::Assembly, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("duplicate")
        expect(action_log.version).to be_present
      end
    end

    context "when copy_categories exists" do
      let(:copy_categories) { true }

      it "duplicates a assembly and the categories" do
        expect { subject.call }.to change { Decidim::Category.count }.by(1)
        expect(Decidim::Category.unscoped.distinct.pluck(:decidim_participatory_space_id).count).to eq 2

        old_assembly_category = Decidim::Category.unscoped.first
        new_assembly_category = Decidim::Category.unscoped.last

        expect(new_assembly_category.name).to eq(old_assembly_category.name)
        expect(new_assembly_category.description).to eq(old_assembly_category.description)
        expect(new_assembly_category.parent).to eq(old_assembly_category.parent)
      end
    end

    context "when copy_components exists" do
      let(:copy_components) { true }

      it "duplicates an assembly and the components" do
        dummy_hook = proc {}
        component.manifest.on :copy, &dummy_hook
        expect(dummy_hook).to receive(:call).with({ new_component: an_instance_of(Decidim::Component), old_component: component })

        expect { subject.call }.to change { Decidim::Component.count }.by(1)

        last_assembly = Decidim::Assembly.last
        last_component = Decidim::Component.all.reorder(:id).last

        expect(last_component.participatory_space).to eq(last_assembly)
        expect(last_component.name).to eq(component.name)
        expect(last_component.settings.attributes.except("dummy_global_translatable_text")).to eq(component.settings.attributes.except("dummy_global_translatable_text"))
        expect(last_component.settings.attributes["dummy_global_translatable_text"]).to include(component.settings.attributes["dummy_global_translatable_text"])
        expect(last_component.step_settings.keys).to eq(component.step_settings.keys)
        expect(last_component.step_settings.values).to eq(component.step_settings.values)
      end
    end

    context "when copying a child assembly" do
      context "when the form is not valid" do
        let(:invalid) { true }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        let!(:assembly_parent) { create :assembly, organization: }
        let!(:assembly) { create :assembly, parent: assembly_parent, organization: }

        it "duplicates an assembly" do
          expect { subject.call }.to change { Decidim::Assembly.count }.by(1)

          old_assembly = Decidim::Assembly.find_by(id: assembly.id)
          new_assembly = Decidim::Assembly.last

          expect(new_assembly.slug).to eq("copied-slug")
          expect(new_assembly.title["en"]).to eq("title")
          expect(new_assembly).not_to be_published
          expect(new_assembly.organization).to eq(old_assembly.organization)
          expect(new_assembly.subtitle).to eq(old_assembly.subtitle)
          expect(new_assembly.description).to eq(old_assembly.description)
          expect(new_assembly.short_description).to eq(old_assembly.short_description)
          expect(new_assembly.promoted).to eq(old_assembly.promoted)
          expect(new_assembly.scope).to eq(old_assembly.scope)
          expect(new_assembly.parent).to eq(old_assembly.parent)
          expect(new_assembly.developer_group).to eq(old_assembly.developer_group)
          expect(new_assembly.local_area).to eq(old_assembly.local_area)
          expect(new_assembly.target).to eq(old_assembly.target)
          expect(new_assembly.participatory_scope).to eq(old_assembly.participatory_scope)
          expect(new_assembly.meta_scope).to eq(old_assembly.meta_scope)
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end
      end
    end
  end
end
