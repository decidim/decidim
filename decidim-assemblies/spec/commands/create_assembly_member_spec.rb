# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssemblyMember do
    subject { described_class.new(form, current_user, assembly) }

    let(:assembly) { create(:assembly) }
    let(:user_entity) { nil }
    let!(:current_user) { create :user, :confirmed, organization: assembly.organization }
    let(:existing_user) { false }
    let(:non_user_avatar) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("avatar.jpg")),
        filename: "avatar.jpeg",
        content_type: "image/jpeg"
      )
    end
    let(:form_klass) { Admin::AssemblyMemberForm }
    let(:form_params) do
      {
        assembly_member: {
          weight: 0,
          full_name: "Full name",
          gender: Faker::Lorem.word,
          birthday: Faker::Date.birthday(min_age: 20, max_age: 65),
          birthplace: Faker::Demographic.demonym,
          ceased_date: nil,
          designation_date: Time.current,
          position: Decidim::AssemblyMember::POSITIONS.sample,
          position_other: "other",
          existing_user:,
          non_user_avatar:,
          user_id: user_entity&.id
        }
      }
    end
    let(:form) do
      form_klass.from_params(
        form_params
      ).with_context(
        current_user:,
        current_organization: assembly.organization
      )
    end

    context "when the form is not valid" do
      let(:existing_user) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      context "when image is invalid" do
        let(:existing_user) { false }
        let(:non_user_avatar) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Decidim::Dev.asset("invalid.jpeg")),
            filename: "avatar.jpeg",
            content_type: "image/jpeg"
          )
        end

        it "prevents uploading" do
          expect { subject.call }.not_to raise_error
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    context "when everything is ok" do
      let(:assembly_member) { Decidim::AssemblyMember.last }

      it "creates an assembly" do
        expect { subject.call }.to change { Decidim::AssemblyMember.count }.by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the assembly" do
        subject.call
        expect(assembly_member.assembly).to eq assembly
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::AssemblyMember, current_user, hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "with an existing user in the platform" do
        let!(:user_entity) { create(:user, organization: assembly.organization) }
        let(:existing_user) { true }

        it "sets the user" do
          subject.call
          expect(assembly_member.user).to eq user_entity
        end

        it "notifies the user" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .once
            .with(
              event: "decidim.events.assemblies.create_assembly_member",
              event_class: Decidim::Assemblies::CreateAssemblyMemberEvent,
              resource: assembly,
              followers: a_collection_containing_exactly(user_entity)
            )

          subject.call
          expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("mailers")
        end
      end

      context "with an existing group in the platform" do
        let!(:member1) { create(:user, organization: assembly.organization) }
        let!(:member2) { create(:user, organization: assembly.organization) }
        let!(:user_entity) { create(:user_group, :verified, users: [member1, member2], organization: assembly.organization) }
        let(:existing_user) { true }

        it "sets the group" do
          subject.call
          expect(assembly_member.user).to eq user_entity
        end

        it "notifies the group members" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .once
            .with(
              event: "decidim.events.assemblies.create_assembly_member",
              event_class: Decidim::Assemblies::CreateAssemblyMemberEvent,
              resource: assembly,
              followers: a_collection_containing_exactly(member1, member2)
            )

          subject.call
          expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.twice.on_queue("mailers")
        end
      end
    end
  end
end
