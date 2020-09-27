# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssemblyMember do
    subject { described_class.new(form, current_user, assembly) }

    let(:assembly) { create(:assembly) }
    let(:user) { nil }
    let!(:current_user) { create :user, :confirmed, organization: assembly.organization }
    let(:form) do
      instance_double(
        Admin::AssemblyMemberForm,
        invalid?: invalid,
        full_name: "Full name",
        user: user,
        attributes: {
          weight: 0,
          full_name: "Full name",
          gender: Faker::Lorem.word,
          birthday: Faker::Date.birthday(min_age: 20, max_age: 65),
          birthplace: Faker::Demographic.demonym,
          ceased_date: nil,
          designation_date: Time.current,
          designation_mode: "designation mode",
          position: Decidim::AssemblyMember::POSITIONS.sample,
          position_other: "other"
        }
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
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
        let!(:user) { create(:user, organization: assembly.organization) }

        it "sets the user" do
          subject.call
          expect(assembly_member.user).to eq user
        end

        it "notifies the user" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .once
            .with(
              event: "decidim.events.assemblies.create_assembly_member",
              event_class: Decidim::Assemblies::CreateAssemblyMemberEvent,
              resource: assembly,
              followers: a_collection_containing_exactly(user)
            )

          subject.call
          expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
        end
      end
    end
  end
end
