# frozen_string_literal: true

require "spec_helper"

shared_examples_for "coauthorable" do
  let(:creator_author) { coauthorable.author }

  describe "authorable interface" do
    describe "author" do
      context "when there is one author" do
        it "returns the only coauthor" do
          expect(coauthorable.author).to eq(creator_author)
        end
      end
      context "when there are many authors" do
        let(:other_authors) { create_list(:user, 4, organization: coauthorable.component.participatory_space.organization) }
        before do
          coauthorable.authors+= other_authors
        end

        it "returns the first coauthor" do
          expect(coauthorable.author).to eq(creator_author)
        end
      end
    end
    describe "user_group" do
      context "when there is NO user_group" do
        it "returns nil"
      end

      context "when there is one user_group" do
        it "returns the only user_group"
      end

      context "when there are many user_groups" do
        it "returns the first user_group"
      end
    end

    describe "authored by? user" do
      context "when there are no coauthors"
      context "when the checked user is one of the coauthors"
      context "when the checked user is one of the coauthors user_groups"
    end

    describe "normalized_author" do
      context "when there are no coauthors"
      context "when there are many coauthors"
    end
  end
end
