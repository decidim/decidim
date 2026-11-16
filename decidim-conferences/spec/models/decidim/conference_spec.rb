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

    context "when the conference is trashed" do
      let(:user) { create(:user, organization: conference.organization) }
      let!(:user_role) { create(:conference_user_role, conference:, user:, role: "admin") }

      it "keeps the user roles, as they are not soft deletable" do
        subject.destroy!

        expect(Decidim::ConferenceUserRole.where(id: user_role.id)).to exist
      end

      it "restores the user roles with the assembly" do
        subject.destroy!
        subject.restore

        expect(subject.reload.conference_user_roles).to contain_exactly(user_role)
      end

      it "removes the user roles when the assembly is permanently deleted" do
        subject.really_destroy!

        expect(Decidim::ConferenceUserRole.where(id: user_role.id)).not_to exist
      end

      it "removes all user roles when the association cache is stale at permanent deletion" do
        subject.conference_user_roles.to_a # load the association cache

        # Create a role through a different instance so the loaded collection above is stale
        Decidim::Conference.find(subject.id).conference_user_roles.create!(user:, role: "collaborator")

        subject.really_destroy!

        expect(Decidim::ConferenceUserRole.where(conference: subject.id)).not_to exist
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
