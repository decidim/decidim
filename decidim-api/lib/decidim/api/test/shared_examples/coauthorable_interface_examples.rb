# frozen_string_literal: true

require "spec_helper"

shared_examples_for "coauthorable interface" do
  describe "author" do
    let(:author) { model.creator_author }

    describe "with a regular user" do
      let(:query) { "{ author { name } }" }

      it "returns the user's name as the author name" do
        expect(response["author"]["name"]).to eq(author.name)
      end
    end

    describe "with a several coauthors" do
      let(:query) { "{ author { name } authors { name } authorsCount }" }
      let(:coauthor) { create(:user, :confirmed, organization: model.participatory_space.organization) }

      before do
        model.add_coauthor coauthor
        model.save!
      end

      context "when both are users" do
        it "returns 2 total co-authors" do
          expect(response["authorsCount"]).to eq(2)
        end

        it "returns an array of authors" do
          expect(response["authors"].count).to eq(2)
          expect(response["authors"]).to include("name" => author.name)
          expect(response["authors"]).to include("name" => coauthor.name)
        end

        it "returns a main author" do
          expect(response["author"]["name"]).to eq(author.name)
        end
      end

      context "when author is the organization" do
        let(:model) { create(:proposal, :official, component:) }

        it "returns 2 total co-authors" do
          expect(response["authorsCount"]).to eq(2)
        end

        it "returns 1 author in authors array" do
          expect(response["authors"].count).to eq(1)
          expect(response["authors"]).to include("name" => coauthor.name)
        end

        it "does not return a main author" do
          expect(response["author"]).to eq(nil)
        end
      end

      context "when author is a meeting" do
        let(:model) { create(:proposal, :official_meeting, component:) }

        it "returns 2 total co-authors" do
          expect(response["authorsCount"]).to eq(2)
        end

        it "returns 1 author in authors array" do
          expect(response["authors"].count).to eq(1)
          expect(response["authors"]).to include("name" => coauthor.name)
        end

        it "does not return a main author" do
          expect(response["author"]).to eq(nil)
        end
      end
    end
  end
end
