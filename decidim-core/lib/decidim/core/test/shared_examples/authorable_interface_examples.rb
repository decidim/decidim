# frozen_string_literal: true

require "spec_helper"

shared_examples_for "authorable interface" do
  describe "author" do
    describe "with a regular user" do
      let(:author) { create(:user, organization: model.participatory_space.organization) }
      let(:query) { "{ author { name } }" }

      before do
        model.update(author: author, user_group: nil)
      end

      it "includes the user's ID" do
        expect(response["author"]["name"]).to eq(author.name)
      end
    end

    describe "with a user group" do
      let(:user_group) { create(:user_group, organization: model.participatory_space.organization) }
      let(:query) { "{ author { name } }" }

      before do
        model.update(user_group: user_group, author: nil)
      end

      it "includes the user's ID" do
        expect(response["author"]["name"]).to eq(user_group.name)
      end
    end
  end
end
