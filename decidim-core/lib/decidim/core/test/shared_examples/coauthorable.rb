# frozen_string_literal: true

require "spec_helper"

shared_examples_for "coauthorable" do
  describe "authorable interface" do
    let!(:creator_author) { coauthorable.authors.first }
    let(:other_authors) { create_list(:user, 5, organization: coauthorable.component.participatory_space.organization) }
    let(:official_author) { creator_author.organization }

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

          coauthorable.add_coauthor(
            official_author
          )
        end

        it "returns an array of identities" do
          identities = [creator_author]
          identities += other_authors
          identities += [official_author]
          expect(coauthorable.identities.to_a).to match_array(identities)
        end
      end
    end
  end
end
