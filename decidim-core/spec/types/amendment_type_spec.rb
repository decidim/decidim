# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe AmendmentType do
      include_context "with a graphql class type"

      let(:model) do
        double(
          id: 1101,
          state: "some_status",
          decidim_amendable_type: "type1",
          decidim_emendation_type: "type2",
          amender: user,
          amendable:,
          emendation:
        )
      end
      let(:user) { create(:user) }
      let(:amendable) { create(:proposal) }
      let(:emendation) { create(:proposal) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the user" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "amender" do
        let(:query) { "{ amender { name } }" }

        it "returns the user" do
          expect(response["amender"]["name"]).to eq(user.name)
        end
      end

      describe "state" do
        let(:query) { "{ state }" }

        it "returns the status as a string" do
          expect(response["state"]).to eq("some_status")
        end
      end

      describe "amendableType" do
        let(:query) { "{ amendableType }" }

        it "returns the amendableType as a string" do
          expect(response["amendableType"]).to eq("type1")
        end
      end

      describe "emendationType" do
        let(:query) { "{ emendationType }" }

        it "returns the emendationType as a string" do
          expect(response["emendationType"]).to eq("type2")
        end
      end

      describe "emendation" do
        let(:query) { '{ emendation { ...on Proposal { title { translation(locale: "en")} } } }' }

        it "returns the emendation as a string" do
          expect(response["emendation"]["title"]["translation"]).to eq(emendation.title["en"])
        end
      end

      describe "amendable" do
        let(:query) { '{ amendable { ...on Proposal { title { translation(locale: "en")} } } }' }

        it "returns the amendable as a string" do
          expect(response["amendable"]["title"]["translation"]).to eq(amendable.title["en"])
        end
      end
    end
  end
end
