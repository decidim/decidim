# frozen_string_literal: true

require "spec_helper"

shared_examples_for "coauthorable" do
  describe "authorable interface" do
    let!(:creator_author) { coauthorable.authors.first }
    let(:other_authors) { create_list(:user, 5, organization: coauthorable.component.participatory_space.organization) }
    let(:other_user_groups) { create_list(:user_group, 5, organization: creator_author.organization, users: [creator_author]) }

    # let(:list_of_coauthor_users) do
    #   list= []
    #   5.times do
    #     list << Decidim::Coauthorship.create(author: create(:user, organization: creator_author.organization), coauthorable: coauthorable)
    #   end
    #   list
    # end

    describe "authors" do
      context "when there is one author" do
        it "returns the only coauthor" do
          expect(coauthorable.authors).to eq([creator_author])
        end
      end

      context "when there are many authors" do
        before { coauthorable.authors = other_authors }

        it "returns all coauthors" do
          expect(coauthorable.authors).to eq(other_authors)
        end
      end
    end

    describe "user_groups" do
      context "when there is NO user_group" do
        it "returns empty array" do
          expect(coauthorable.user_groups).to eq([])
        end
      end

      context "when there is one user_group" do
        it "returns the only user_group"
      end

      context "when there are many user_groups" do
        it "returns the first user_group"
      end
    end

    describe "authored by? user" do
      context "when there are no coauthors" do
        before { coauthorable.authors.clear }

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

      context "when the checked user is one of the coauthors user_groups"
    end

    describe "identities" do
      context "when there are no coauthors" do
        before { coauthorable.authors.clear }

        it "returns an empty list" do
        end
      end
      context "when there are many coauthors of both types" do
        before do
          other_authors.reverse.each { |author| coauthorable.authors << author }
          other_user_groups.reverse.each { |user_group| coauthorable.user_groups << user_group }
        end
        it "returns an array of identities" do
          identities = other_authors
          identities << creator_author
          identities += other_user_groups
          expect(coauthorable.identities).to eq(identities)
        end
      end
    end
  end
end
