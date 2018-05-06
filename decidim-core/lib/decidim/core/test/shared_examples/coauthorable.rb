# frozen_string_literal: true

require "spec_helper"

shared_examples_for "coauthorable" do
  describe "authorable interface" do
    let(:creator_author) { puts "@creator_author #{coauthorable.authors.to_a}"; coauthorable.authors.first }

    describe "authors" do
      context "when there is one author" do
        it "returns the only coauthor" do
          expect(coauthorable.authors).to eq([creator_author])
        end
      end

      context "when there are many authors" do
        let(:other_authors) { create_list(:user, 5, organization: coauthorable.component.participatory_space.organization) }

        before do
          coauthorable.authors = other_authors
        end

        it "returns the all coauthors" do
          expect(coauthorable.authors).to eq(other_authors)
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
      context "when there are no coauthors" do
        it "returns false"
      end
      context "when the checked user is one of the coauthors"
      context "when the checked user is one of the coauthors user_groups"
    end

    describe "normalized_authors" do
      context "when there are no coauthors" do
        it "returns an empty list"
      end
      context "when there are many coauthors"
    end
  end
end
