# frozen_string_literal: true

require "spec_helper"

shared_examples_for "coauthorable interface" do
  describe "author" do
    let(:author) { model.creator_author }

    describe "with a regular user" do
      let(:query) { "{ author { name } }" }

      it "includes the user's ID" do
        expect(response["author"]["name"]).to eq(author.name)
      end
    end

    describe "with a user group" do
      let(:user_group) { create(:user_group, :verified, organization: model.participatory_space.organization, users: [author]) }
      let(:query) { "{ author { name } }" }

      before do
        coauthorship = model.coauthorships.first
        coauthorship.update!(user_group: user_group)
      end

      it "includes the user's ID" do
        expect(response["author"]["name"]).to eq(user_group.name)
      end
    end
  end
end
