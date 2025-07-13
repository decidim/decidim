# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssembly do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let(:errors) { double.as_null_object }
    let(:participatory_processes) do
      create_list(
        :participatory_process,
        3,
        organization:
      )
    end
    let(:related_process_ids) { [participatory_processes.map(&:id)] }
    let(:hero_image) { nil }
    let(:banner_image) { nil }
    let(:taxonomizations) do
      2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
    end

    let(:form) do
      instance_double(
        Admin::AssemblyForm,
        current_user:,
        invalid?: invalid,
        title: { en: "title" },
        subtitle: { en: "subtitle" },
        weight: 1,
        slug: "slug",
        meta_scope: { en: "meta scope" },
        hero_image:,
        banner_image:,
        promoted: nil,
        developer_group: { en: "developer group" },
        local_area: { en: "local" },
        target: { en: "target" },
        participatory_scope: { en: "participatory scope" },
        participatory_structure: { en: "participatory structure" },
        description: { en: "description" },
        short_description: { en: "short_description" },
        organization:,
        taxonomizations:,
        parent: nil,
        private_space: false,
        errors:,
        participatory_processes_ids: related_process_ids,
        purpose_of_action: { en: "purpose of action" },
        composition: { en: "composition of internal working groups" },
        creation_date: 1.day.from_now,
        created_by: "others",
        created_by_other: { en: "other created by" },
        duration: 2.days.from_now,
        included_at: 5.days.from_now,
        closing_date: 5.days.from_now,
        closing_date_reason: { en: "closing date reason" },
        internal_organisation: { en: "internal organisation" },
        is_transparent: true,
        special_features: { en: "special features" },
        twitter_handler: "lorem",
        facebook_handler: "lorem",
        instagram_handler: "lorem",
        youtube_handler: "lorem",
        github_handler: "lorem",
        announcement: { en: "announcement_lorem" }
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
      let(:hero_image) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("invalid.jpeg")),
          filename: "avatar.jpeg",
          content_type: "image/jpeg"
        )
      end
      let(:banner_image) { hero_image }

      before do
        allow(Decidim::ActionLogger).to receive(:log).and_return(true)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds errors to the form" do
        expect(errors).to receive(:add).with(:hero_image, "File resolution is too large")
        expect(errors).to receive(:add).with(:banner_image, "File resolution is too large")
        subject.call
      end
    end

    context "when the uploaded hero image has too large dimensions" do
      let(:hero_image) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("5000x5000.png")),
          filename: "5000x5000.png",
          content_type: "image/png"
        )
      end
      let(:banner_image) { nil }
      let(:form) do
        Admin::AssemblyForm.from_params(
          title: { en: "title" },
          subtitle: { en: "subtitle" },
          slug: "slug",
          hero_image:,
          banner_image:,
          description: { en: "description" },
          short_description: { en: "short_description" },
          organization:
        ).with_context(
          current_organization: organization,
          current_user:
        )
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
        expect(form.errors.messages[:hero_image]).to contain_exactly("File resolution is too large")
      end
    end

    context "when everything is ok" do
      let(:assembly) { Decidim::Assembly.last }

      it "creates an assembly" do
        expect { subject.call }.to change(Decidim::Assembly, :count).by(1)
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

      it "links to taxonomizations" do
        subject.call

        expect(assembly.taxonomizations).to match_array(taxonomizations)
      end

      context "when no taxonomizations are set" do
        let(:taxonomizations) { [] }

        it "taxonomizations are empty" do
          subject.call

          expect(assembly.taxonomizations).to be_empty
        end
      end

      it "links participatory processes" do
        subject.call
        linked_participatory_processes = assembly.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
        expect(linked_participatory_processes).to match_array(participatory_processes)
      end

      context "when sorting by weight" do
        let!(:process_one) { create(:participatory_process, organization:, weight: 2) }
        let!(:process_two) { create(:participatory_process, organization:, weight: 1) }
        let(:related_process_ids) { [process_one.id, process_two.id] }

        it "links processes in right way" do
          subject.call

          linked_processes = assembly.linked_participatory_space_resources(:participatory_process, "included_participatory_processes")
          expect(linked_processes.first).to eq(process_two)
        end
      end

      context "when linking draft processes" do
        let!(:process_one) { create(:participatory_process, :unpublished, organization:, weight: 2) }
        let!(:process_two) { create(:participatory_process, organization:, weight: 1) }
        let(:related_process_ids) { [process_one.id, process_two.id] }

        it "links processes in right way" do
          subject.call

          linked_processes = assembly.linked_participatory_space_resources(:participatory_process, "included_participatory_processes")
          expect(linked_processes.size).to eq(1)
          expect(linked_processes.first).to eq(process_two)
        end
      end
    end
  end
end
