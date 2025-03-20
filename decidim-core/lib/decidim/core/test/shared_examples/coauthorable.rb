# frozen_string_literal: true

require "spec_helper"

shared_examples_for "coauthorable" do
  describe "authorable interface" do
    let!(:creator_author) { coauthorable.authors.first }
    let(:other_authors) { create_list(:user, 5, organization: coauthorable.component.participatory_space.organization) }
    let(:other_user_groups) { create_list(:user_group, 5, :verified, organization: creator_author.organization, users: [creator_author]) }

    describe "authors" do
      context "when there is one author" do
        it "returns the only coauthor" do
          expect(coauthorable.authors).to eq([creator_author])
        end
      end

      context "when there are many authors" do
        before do
          coauthorable.coauthorships.destroy_all
          coauthorable.reload

          other_authors.each do |author|
            coauthorable.add_coauthor(author)
          end
        end

        it "returns all coauthors" do
          expect(coauthorable.reload.authors).to match_array(other_authors)
        end
      end
    end

    describe "user_groups" do
      let(:user_group) do
        create(:user_group,
               :verified,
               organization: creator_author.organization,
               users: [creator_author])
      end

      context "when there is NO user_group" do
        it "returns empty array" do
          expect(coauthorable.user_groups).to eq([])
        end
      end

      context "when there is one user_group" do
        before do
          coauthorship = coauthorable.coauthorships.first
          coauthorship.user_group = user_group
          coauthorship.save
        end

        it "returns the only user_group" do
          expect(coauthorable.user_groups).to eq([user_group])
        end
      end

      context "when there are many user_groups" do
        before do
          coauthorable.coauthorships.clear
          other_user_groups.each do |ug|
            Decidim::Coauthorship.create(author: ug.memberships.first.user, user_group: ug, coauthorable:)
          end
        end

        it "returns all user_groups" do
          expect(coauthorable.user_groups).to eq(other_user_groups)
        end
      end
    end

    describe "authored by? user" do
      context "when there are no coauthors" do
        before do
          coauthorable.coauthorships.clear
          coauthorable.reload
        end

        it "returns false" do
          expect(coauthorable.authored_by?(creator_author)).to be(false)
        end
      end

      context "when the checked user is one of the coauthors" do
        before do
          other_authors.each { |author| coauthorable.authors << author }
        end

        it "returns true" do
          expect(coauthorable.authored_by?(creator_author)).to be(true)
        end
      end
    end

    describe "identities" do
      context "when there are no coauthors" do
        before do
          coauthorable.coauthorships.clear
          coauthorable.reload
        end

        it "returns an empty list" do
          expect(coauthorable.identities).to be_blank
        end
      end

      context "when there are many coauthors of both types" do
        before do
          other_authors.each do |author|
            coauthorable.add_coauthor(author)
          end

          other_user_groups.each do |user_group|
            coauthorable.add_coauthor(
              user_group.memberships.first.user,
              user_group:
            )
          end
        end

        it "returns an array of identities" do
          identities = [creator_author]
          identities += other_authors
          identities += other_user_groups
          expect(coauthorable.identities.to_a).to match_array(identities)
        end
      end
    end
  end
end
