# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Pages {
        page(id: #{page.id}){
          body {
            translation(locale:"#{locale}")
          }
          createdAt
          id
          title {
            translation(locale:"#{locale}")
          }
          updatedAt
          url
        }
      }
)
    end
  end
  let(:component_type) { "Pages" }
  let!(:current_component) { create(:page_component, participatory_space: participatory_process) }
  let!(:page) { create(:page, component: current_component) }

  let(:page_single_result) do
    {
      "body" => { "translation" => page.body[locale] },
      "createdAt" => page.created_at.to_time.iso8601,
      "id" => page.id.to_s,
      "title" => { "translation" => page.title[locale] },
      "updatedAt" => page.updated_at.to_time.iso8601,
      "url" => Decidim::ResourceLocatorPresenter.new(page).url
    }
  end

  let(:page_data) do
    {
      "__typename" => "Pages",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Page" },
      "pages" => {
        "edges" => [
          {
            "node" => page_single_result
          }
        ]
      },
      "url" => Decidim::EngineRouter.main_proxy(current_component).root_url,
      "weight" => 0
    }
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Pages {
        pages{
          edges{
            node{
              body {
                translation(locale:"#{locale}")
              }
              createdAt
              id
              title {
                translation(locale:"#{locale}")
              }
              updatedAt
              url
            }
          }
        }
      }
)
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first).to eq(page_data) }
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["page"]).to eq(page_single_result) }
  end

  include_examples "with resource visibility" do
    let(:component_factory) { :page_component }
    let(:lookout_key) { "page" }
    let(:query_result) { page_single_result }
  end
end
