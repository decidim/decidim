# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::CreateParticipatoryProcess, versioning: true do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:participatory_process_group) { create :participatory_process_group, organization: organization }
    let(:scope) { create :scope, organization: organization }
    let(:current_user) { create :user, :admin, organization: organization }
    let(:errors) { double.as_null_object }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessForm,
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
        start_date: nil,
        end_date: nil,
        description: { en: "description" },
        short_description: { en: "short_description" },
        current_user: current_user,
        current_organization: organization,
        scopes_enabled: true,
        private_space: false,
        scope: scope,
        errors: errors,
        participatory_process_group: participatory_process_group
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the process is not persisted" do
      let(:invalid_process) do
        instance_double(
          Decidim::ParticipatoryProcess,
          persisted?: false,
          valid?: false,
          errors: {
            hero_image: "Image too big",
            banner_image: "Image too big"
          }
        ).as_null_object
      end

      before do
        expect(Decidim::ParticipatoryProcess).to receive(:new).and_return(invalid_process)
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
      let(:process) { Decidim::ParticipatoryProcess.last }

      it "creates a participatory process" do
        expect { subject.call }.to change { Decidim::ParticipatoryProcess.count }.by(1)
      end

      it "traces the creation", versioning: true do
        expect(Decidim::ActionLogger)
          .to receive(:log)
          .with("create", current_user, a_kind_of(Decidim::ParticipatoryProcess), a_kind_of(Integer))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "create"
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "adds the default active step" do
        subject.call
        expect(process.steps.count).to eq(1)
        expect(process.steps.first).to be_active
      end

      it "adds the admins as followers" do
        subject.call
        expect(current_user.follows?(process)).to be true
      end
    end
  end
end
