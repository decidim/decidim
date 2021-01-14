# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Meetings
    describe AgendaType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:agenda, :with_agenda_items) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the agenda's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en") } }' }

        it "returns the service's title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "items" do
        let(:query) { "{ items { id } }" }

        it "returns the agenda's items" do
          ids = response["items"].map { |item| item["id"] }
          expect(ids).to include(*model.agenda_items.map(&:id).map(&:to_s))
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
