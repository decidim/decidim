# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Pages
    describe PagesType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:page_component) }

      it_behaves_like "a component query type"

      describe "pages" do
        let!(:component_pages) { create_list(:page, 2, component: model) }
        let!(:other_pages) { create_list(:page, 2) }

        let(:query) { "{ pages { edges { node { id } } } }" }

        it "returns the published pages" do
          ids = response["pages"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_pages.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_pages.map(&:id).map(&:to_s))
        end
      end

      describe "page" do
        let(:query) { "query Page($id: ID!){ page(id: $id) { id } }" }
        let(:variables) { { id: page.id.to_s } }

        context "when the page belongs to the component" do
          let!(:page) { create(:page, component: model) }

          it "finds the page" do
            expect(response["page"]["id"]).to eq(page.id.to_s)
          end
        end

        context "when the page doesn't belong to the component" do
          let!(:page) { create(:page, component: create(:page_component)) }

          it "returns null" do
            expect(response["page"]).to be_nil
          end
        end
      end
    end
  end
end
