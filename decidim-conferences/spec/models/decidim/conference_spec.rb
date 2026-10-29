# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Conference do
    subject { conference }

    let(:conference) { build(:conference, slug: "my-slug") }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }
    it { is_expected.to act_as_paranoid }

    include_examples "publicable"
    include_examples "resourceable"

    describe "associations" do
      let(:user) { create(:user) }
      let(:conference) { create(:conference, organization: user.organization) }

      it "has an association of conference_user_roles" do
        user_role = create(:conference_user_role, conference:, user:, role: "admin")

        expect(conference.conference_user_roles).to eq([user_role])
      end

      it "uses the conference_user_roles association as the inverse of the user role" do
        create(:conference_user_role, conference:, user:, role: "admin")

        expect(conference.conference_user_roles.first.conference).to be(conference)
      end

      context "when the conference is trashed" do
        let(:user_role) { create(:conference_user_role, conference:, user:, role: "admin") }

        it "keeps the user roles, as they are not soft deletable" do
          user_role

          conference.destroy!

          expect(Decidim::ConferenceUserRole.where(id: user_role.id)).to exist
        end

        it "restores the user roles with the conference" do
          user_role

          conference.destroy!
          conference.restore

          expect(conference.reload.conference_user_roles).to contain_exactly(user_role)
        end

        it "removes the user roles when the conference is permanently deleted" do
          user_role

          conference.really_destroy!

          expect(Decidim::ConferenceUserRole.where(id: user_role.id)).not_to exist
        end

        it "removes all user roles when the association cache is stale at permanent deletion" do
          user_role
          conference.conference_user_roles.to_a # load the association cache

          # Create a role through a different instance so the loaded collection above is stale
          Decidim::Conference.find(conference.id).conference_user_roles.create!(user:, role: "collaborator")

          conference.really_destroy!

          expect(Decidim::ConferenceUserRole.where(decidim_conference_id: conference.id)).not_to exist
        end
      end
    end

    context "when there is a conference with the same slug in the same organization" do
      let!(:external_conference) { create(:conference, organization: conference.organization, slug: "my-slug") }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:slug]).to eq ["has already been taken"]
      end
    end

    context "when there is a conference with the same slug in another organization" do
      let!(:external_conference) { create(:conference, slug: "my-slug") }

      it { is_expected.to be_valid }
    end

    describe "#has_published_registration_types?" do
      subject { conference.has_published_registration_types? }

      context "when conference has no registration type" do
        it { is_expected.to be_falsey }
      end

      context "when conference has registration types" do
        let!(:registration_types) do
          create_list(:registration_type, 5, conference:)
        end

        it { is_expected.to be_truthy }

        context "and the registration types are unpublished" do
          let!(:registration_types) do
            create_list(:registration_type, 5, :unpublished, conference:)
          end

          it { is_expected.to be_falsey }
        end
      end
    end

    describe "taxonomies" do
      let!(:taxonomy) { create(:taxonomy, :with_parent) }
      let(:conference) { build(:conference, taxonomies: [taxonomy], organization: taxonomy.organization) }

      it { is_expected.to be_valid }

      context "when a root taxonomy is assigned" do
        let(:taxonomy) { create(:taxonomy) }

        it "is not valid" do
          expect(subject).not_to be_valid
        end
      end

      context "when a taxonomy from another organization is assigned" do
        let!(:organization) { create(:organization) }
        let(:conference) { build(:conference, taxonomies: [taxonomy]) }

        it "is not valid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
