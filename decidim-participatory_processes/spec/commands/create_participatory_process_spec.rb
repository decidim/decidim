# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::CreateParticipatoryProcess, versioning: true do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:participatory_process_group) { create(:participatory_process_group, organization:) }
    let(:current_user) { create(:user, :admin, organization:) }
    let(:errors) { double.as_null_object }
    let(:related_process_ids) { [] }
    let(:weight) { 1 }
    let(:hero_image) { nil }
    let(:taxonomizations) do
      2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
    end

    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessForm,
        invalid?: invalid,
        title: { en: "title" },
        subtitle: { en: "subtitle" },
        weight:,
        slug: "slug",
        meta_scope: { en: "meta scope" },
        hero_image:,
        promoted: nil,
        developer_group: { en: "developer group" },
        local_area: { en: "local" },
        target: { en: "target" },
        participatory_scope: { en: "participatory scope" },
        participatory_structure: { en: "participatory structure" },
        start_date: nil,
        end_date: nil,
        description: { en: "description" },
        short_description: { en: "short_description" },
        current_user:,
        current_organization: organization,
        organization:,
        private_space: false,
        taxonomizations:,
        errors:,
        related_process_ids:,
        participatory_process_group:,
        announcement: { en: "message" }
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
      let(:hero_image) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("invalid.jpeg")),
          filename: "avatar.jpeg",
          content_type: "image/jpeg"
        )
      end

      before do
        allow(Decidim::ActionLogger).to receive(:log).and_return(true)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds errors to the form" do
        expect(errors).to receive(:add).with(:hero_image, "File resolution is too large")
        subject.call
      end
    end

    context "when everything is ok" do
      let(:process) { Decidim::ParticipatoryProcess.last }

      it "creates a participatory process" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcess, :count).by(1)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create)
          .with(Decidim::ParticipatoryProcess, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
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

      it "links to taxonomizations" do
        subject.call

        expect(process.taxonomizations).to match_array(taxonomizations)
      end

      context "when no taxonomizations are set" do
        let(:taxonomizations) { [] }

        it "taxonomizations are empty" do
          subject.call

          expect(process.taxonomizations).to be_empty
        end
      end

      context "with related processes" do
        let!(:another_process) { create(:participatory_process, organization:) }
        let(:related_process_ids) { [another_process.id] }

        it "links related processes" do
          subject.call

          linked_processes = process.linked_participatory_space_resources(:participatory_process, "related_processes")
          expect(linked_processes).to contain_exactly(another_process)
        end

        context "when sorting by weight" do
          let!(:process_one) { create(:participatory_process, organization:, weight: 2) }
          let!(:process_two) { create(:participatory_process, organization:, weight: 1) }
          let(:related_process_ids) { [process_one.id, process_two.id] }

          it "links processes in right way" do
            subject.call

            linked_processes = process.linked_participatory_space_resources(:participatory_process, "related_processes")
            expect(linked_processes.first).to eq(process_two)
          end
        end
      end
    end
  end
end
