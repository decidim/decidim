# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe TraceVersionType do
      include_context "with a graphql class type"

      let(:user) { create(:user) }
      let(:change) do
        {
          "test" => "test object"
        }
      end
      let(:model) do
        double(
          created_at: Time.new(2018, 2, 22, 9, 47, 0, "+01:00"),
          id: 1,
          whodunnit: user,
          changeset: change
        )
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns a string" do
          expect(response["id"]).to eq("1")
        end
      end

      describe "created_at" do
        let(:query) { "{ createdAt }" }

        it "returns the formatted date" do
          expect(response["createdAt"]).to eq("2018-02-22T09:47:00+01:00")
        end
      end

      describe "editor" do
        let(:query) { "{ editor { name } }" }

        context "when last editor is a user" do
          it "returns the user" do
            expect(response["editor"]["name"]).to eq(user.name)
          end
        end

        context "when last editor is a string" do
          let(:user) { "test suite" }

          it "returns nil" do
            expect(response["editor"]).to be_nil
          end
        end
      end

      describe "changeset" do
        let(:query) { "{ changeset }" }

        it "returns a Json object" do
          expect(response["changeset"]).to eq("test" => "test object")
        end
      end
    end
  end
end
