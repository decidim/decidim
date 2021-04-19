# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Meetings
    describe AgendaItemType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:agenda_item, :with_parent, :with_children) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the items's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en") } }' }

        it "returns the service's title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en") } }' }

        it "returns the service's description" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "duration" do
        let(:query) { "{ duration }" }

        it "returns the service's duration" do
          expect(response["duration"]).to eq(model.duration)
        end
      end

      describe "position" do
        let(:query) { "{ position }" }

        it "returns the service's position" do
          expect(response["position"]).to eq(model.position)
        end
      end

      describe "parent" do
        let(:query) { "{ parent { id } }" }

        it "returns the service's parent" do
          expect(response["parent"]["id"]).to eq(model.parent.id.to_s)
        end
      end

      describe "agenda" do
        let(:query) { "{ agenda { id } }" }

        it "returns the service's agenda" do
          expect(response["agenda"]["id"]).to eq(model.agenda.id.to_s)
        end
      end

      describe "items" do
        let(:query) { "{ items { id } }" }

        it "returns the items's sub-items" do
          ids = response["items"].map { |item| item["id"] }
          expect(ids).to include(*model.agenda_item_children.map(&:id).map(&:to_s))
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when was this query created at" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when was this query updated at" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end
    end
  end
end
