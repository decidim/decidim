# frozen_string_literal: true

require "spec_helper"

shared_examples_for "authorable interface" do
  describe "author" do
    describe "when author is not present" do
      let(:author) { nil }
      let(:query) { "{ author { name } }" }

      before do
        model.update(author:)
      end

      it "does not include the author" do
        expect(response["author"]).to be_nil
      end
    end

    describe "with a regular user" do
      let(:author) { create(:user, organization: model.participatory_space.organization) }
      let(:query) { "{ author { name } }" }

      before do
        model.update(author:, user_group: nil)
      end

      it "includes the user's name" do
        expect(response["author"]["name"]).to eq(author.name)
      end
    end

    describe "with a user group" do
      let(:user_group) { create(:user_group, organization: model.participatory_space.organization) }
      let(:query) { "{ author { name } }" }

      before do
        model.update(user_group:, author: nil)
      end

      it "includes the user group's name" do
        expect(response["author"]["name"]).to eq(user_group.name)
      end
    end

    describe "with an organization" do
      let(:organization) { model.participatory_space.organization }
      let(:query) { "{ author { name } }" }

      before do
        model.update(author: organization, user_group: nil)
      end

      it "does not return a main author" do
        expect(response["author"]).to eq(nil)
      end
    end
  end
end
