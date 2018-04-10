# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssembly do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, :confirmed, organization: organization }
    let(:scope) { create :scope, organization: organization }
    let(:area) { create :area, organization: organization }
    let(:errors) { double.as_null_object }
    let(:participatory_processes) do
      create_list(
        :participatory_process,
        3,
        organization: organization
      )
    end
    let(:form) do
      instance_double(
        Admin::AssemblyForm,
        current_user: current_user,
        invalid?: invalid,
        title: { en: "title" },
        subtitle: { en: "subtitle" },
        slug: "slug",
        hashtag: "hashtag",
        meta_scope: "meta scope",
        hero_image: nil,
        banner_image: nil,
        promoted: nil,
        developer_group: "developer group",
        local_area: "local",
        target: "target",
        participatory_scope: "participatory scope",
        participatory_structure: "participatory structure",
        description: { en: "description" },
        short_description: { en: "short_description" },
        current_organization: organization,
        scopes_enabled: true,
        scope: scope,
        area: area,
        parent: nil,
        private_space: false,
        errors: errors,
        participatory_processes_ids: participatory_processes.map(&:id)
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the assembly is not persisted" do
      let(:invalid_assembly) do
        instance_double(
          Decidim::Assembly,
          persisted?: false,
          valid?: false,
          errors: {
            hero_image: "Image too big",
            banner_image: "Image too big"
          }
        ).as_null_object
      end

      before do
        allow(Decidim::ActionLogger).to receive(:log).and_return(true)
        expect(Decidim::Assembly).to receive(:create).and_return(invalid_assembly)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds errors to the form" do
        expect(errors).to receive(:add).with(:hero_image, "Image too big")
        expect(errors).to receive(:add).with(:banner_image, "Image too big")
        subject.call
      end
    end

    context "when everything is ok" do
      let(:assembly) { Decidim::Assembly.last }

      it "creates an assembly" do
        expect { subject.call }.to change { Decidim::Assembly.count }.by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "adds the admins as followers" do
        subject.call
        expect(current_user.follows?(assembly)).to be true
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create)
          .with(Decidim::Assembly, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "links participatory processes" do
        subject.call
        linked_participatory_processes = assembly.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
        expect(linked_participatory_processes).to match_array(participatory_processes)
      end
    end
  end
end
