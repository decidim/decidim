# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::UpdateAssemblyMember do
    subject { described_class.new(form, assembly_member) }

    let!(:assembly) { create(:assembly) }
    let(:assembly_member) { create :assembly_member, :with_user, assembly: assembly }
    let!(:current_user) { create :user, :confirmed, organization: assembly.organization }
    let(:user) { nil }
    let(:form) do
      instance_double(
        Admin::AssemblyMemberForm,
        invalid?: invalid,
        current_user: current_user,
        full_name: "New name",
        user: user,
        attributes: {
          weight: 0,
          full_name: "New name",
          gender: Faker::Lorem.word,
          birthday: Faker::Date.birthday(min_age: 20, max_age: 65),
          birthplace: Faker::Demographic.demonym,
          ceased_date: nil,
          designation_date: Time.current,
          designation_mode: "designation mode",
          position: Decidim::AssemblyMember::POSITIONS.sample,
          position_other: ""
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
      it "updates the assembly full name" do
        expect do
          subject.call
        end.to change { assembly_member.reload && assembly_member.full_name }.from(assembly_member.full_name).to("New name")
      end

      it "broadcasts  ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(assembly_member, current_user, kind_of(Hash), hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "when is an existing user in the platform" do
        let!(:user) { create :user, organization: assembly.organization }

        it "sets the user" do
          expect do
            subject.call
          end.to change { assembly_member.reload && assembly_member.user }.from(assembly_member.user).to(user)
        end
      end
    end
  end
end
