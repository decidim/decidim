# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreateConference do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let(:errors) { double.as_null_object }
    let(:hero_image) { nil }
    let(:taxonomizations) do
      2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
    end
    let(:banner_image) { nil }
    let!(:participatory_processes) do
      create_list(
        :participatory_process,
        3,
        organization:
      )
    end
    let!(:assemblies) do
      create_list(
        :assembly,
        3,
        organization:
      )
    end
    let(:related_processes_ids) { [participatory_processes.map(&:id)] }
    let(:related_assemblies_ids) { [assemblies.map(&:id)] }

    let(:form) do
      instance_double(
        Admin::ConferenceForm,
        current_user:,
        invalid?: invalid,
        title: { en: "title" },
        slogan: { en: "slogan" },
        weight: 1,
        slug: "slug",
        location: "location location",
        hero_image:,
        banner_image:,
        promoted: nil,
        description: { en: "description" },
        short_description: { en: "short_description" },
        current_organization: organization,
        organization:,
        taxonomizations:,
        errors:,
        show_statistics: false,
        objectives: { en: "objectives" },
        start_date: 1.day.from_now,
        end_date: 5.days.from_now,
        registrations_enabled: false,
        available_slots: 0,
        registration_terms: { en: "registrations terms" },
        participatory_processes_ids: related_processes_ids,
        assemblies_ids: related_assemblies_ids
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the conference is not persisted" do
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

    context "when everything is ok" do
      let(:conference) { Decidim::Conference.last }

      it "creates a conference" do
        expect { subject.call }.to change(Decidim::Conference, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "adds the admins as followers" do
        subject.call
        expect(current_user.follows?(conference)).to be true
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create)
          .with(Decidim::Conference, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "links participatory processes" do
        subject.call
        linked_participatory_processes = conference.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
        expect(linked_participatory_processes).to match_array(participatory_processes)
      end

      it "links assemblies" do
        subject.call
        linked_assemblies = conference.linked_participatory_space_resources(:assemblies, "included_assemblies")
        expect(linked_assemblies).to match_array(assemblies)
      end

      it "links to taxonomizations" do
        subject.call

        expect(conference.taxonomizations).to match_array(taxonomizations)
      end

      context "when no taxonomizations are set" do
        let(:taxonomizations) { [] }

        it "taxonomizations are empty" do
          subject.call

          expect(conference.taxonomizations).to be_empty
        end
      end

      context "when sorting linked_participatory_space_resources" do
        let!(:process_one) { create(:participatory_process, organization:, weight: 2) }
        let!(:process_two) { create(:participatory_process, organization:, weight: 1) }
        let(:related_processes_ids) { [process_one.id, process_two.id] }
        let!(:assembly_one) { create(:assembly, organization:) }
        let!(:assembly_two) { create(:assembly, organization:) }
        let(:related_assemblies_ids) { [assembly_one.id, assembly_two.id] }

        it "sorts by created at" do
          subject.call

          linked_assemblies = conference.linked_participatory_space_resources(:assemblies, "included_assemblies")
          expect(linked_assemblies.first).to eq(assembly_one)
        end

        it "sorts by weight" do
          subject.call

          linked_processes = conference.linked_participatory_space_resources(:participatory_process, "included_participatory_processes")
          expect(linked_processes.first).to eq(process_two)
        end
      end

      context "when linking unpublished linked_participatory_space_resources" do
        let!(:process_one) { create(:participatory_process, :unpublished, organization:, weight: 2) }
        let!(:process_two) { create(:participatory_process, organization:, weight: 1) }
        let(:related_processes_ids) { [process_one.id, process_two.id] }
        let!(:assembly_one) { create(:assembly, :unpublished, organization:) }
        let!(:assembly_two) { create(:assembly, organization:) }
        let(:related_assemblies_ids) { [assembly_one.id, assembly_two.id] }

        it "does not include unpublished assemblies" do
          subject.call

          linked_assemblies = conference.linked_participatory_space_resources(:assemblies, "included_assemblies")
          expect(linked_assemblies.first).to eq(assembly_two)
          expect(linked_assemblies.size).to eq(1)
        end
      end
    end
  end
end
