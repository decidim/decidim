# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component" do
    let(:component_fragment) do
      %(
      fragment fooComponent on CollaborativeTexts {
        collaborativeText(id: #{document.id}) {
          author {
            id
          }
          body
          createdAt
          id
          title
          draft
          updatedAt
          versions {
            id
            changeset
            createdAt
            editor {
              id
            }
          }
          versionsCount
        }
      }
    )
    end
  end
  let(:component_type) { "CollaborativeTexts" }
  let!(:current_component) { create(:collaborative_text_component, participatory_space: participatory_process) }
  let!(:document) { create(:collaborative_text_document, component: current_component, published_at: 2.days.ago) }
  let!(:document_version) { create(:collaborative_text_version, document:) }
  let!(:suggestions) { create_list(:collaborative_text_suggestion, 2, document_version: document_version) }
  let(:author) { nil }
  let(:document_single_result) do
    {
      "author" => author,
      "body" => document.body,
      "createdAt" => document.created_at.to_time.iso8601,
      "id" => document.id.to_s,
      "title" => document.title,
      "draft" => document.draft?,
      "updatedAt" => document.updated_at.to_time.iso8601,
      "versions" => [],
      "versionsCount" => 0
    }
  end

  let(:documents_data) do
    {
      "__typename" => "CollaborativeTexts",
      "id" => current_component.id.to_s,
      "name" => { "translation" => translated(current_component.name) },
      "collaborativeTexts" => {
        "edges" => [
          {
            "node" => document_single_result
          }
        ],
        "pageInfo" => {
          "endCursor" => "MQ",
          "hasNextPage" => false,
          "hasPreviousPage" => false,
          "startCursor" => "MQ"
        }
      },
      "weight" => 0
    }
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on CollaborativeTexts {
        collaborativeTexts{
          edges {
            node{
              author {
                id
              }
              body
              createdAt
              id
              title
              draft
              updatedAt
              versions {
                id
                changeset
                createdAt
                editor {
                  id
                }
              }
              versionsCount
            }
          }
          pageInfo{
            endCursor
            hasNextPage
            hasPreviousPage
            startCursor
          }
        }
      }
    )
    end

    context "when unfiltered" do
      it "executes successfully" do
        expect { response }.not_to raise_error
      end

      it { expect(response["participatoryProcess"]["components"].first).to eq(documents_data) }

      context "when author is not the organization" do
        let(:user) { create(:user, :confirmed, organization: participatory_process.organization) }
        let!(:document) { create(:collaborative_text_document, component: current_component, published_at: 2.days.ago, users: [user]) }
        let(:author) { { "id" => user.id.to_s } }

        it { expect(response["participatoryProcess"]["components"].first).to eq(documents_data) }
      end
    end

    context "with params" do
      let(:criteria) { { first: 1 } }

      let(:component_fragment) do
        %(
          fragment fooComponent on CollaborativeTexts {
            collaborativeTexts(#{criteria}){
              edges {
                node{ id }
              }
            }
          }
        )
      end

      let!(:other_document) { create(:collaborative_text_document, created_at: 2.weeks.ago, updated_at: 1.week.ago, component: current_component, published_at: 2.weeks.ago) }
      let(:edges) { response["participatoryProcess"]["components"].first["collaborativeTexts"]["edges"] }

      context "when ordered by" do
        context "with createdAt" do
          let(:criteria) { "order: { createdAt: \"asc\" }" }

          it {
            expect(edges).to eq([
                                  { "node" => { "id" => other_document.id.to_s } },
                                  { "node" => { "id" => document.id.to_s } }
                                ])
          }
        end

        context "with updatedAt" do
          let(:criteria) { "order: { updatedAt: \"asc\" }" }

          it {
            expect(edges).to eq([
                                  { "node" => { "id" => other_document.id.to_s } },
                                  { "node" => { "id" => document.id.to_s } }
                                ])
          }
        end

        context "with id" do
          let(:criteria) { "order: { id: \"asc\" }" }

          it {
            expect(edges).to eq([
                                  { "node" => { "id" => document.id.to_s } },
                                  { "node" => { "id" => other_document.id.to_s } }
                                ])
          }
        end
      end

      context "when filtered by" do
        context "with createdBefore" do
          let(:criteria) { "filter: { createdBefore: \"#{1.week.ago.to_date}\" } " }

          it { expect(edges).to eq([{ "node" => { "id" => other_document.id.to_s } }]) }
        end

        context "with createdSince" do
          let(:criteria) { "filter: { createdSince: \"#{1.week.ago.to_date}\" } " }

          it { expect(edges).to eq([{ "node" => { "id" => document.id.to_s } }]) }
        end

        context "with updatedBefore" do
          let(:criteria) { "filter: { updatedBefore: \"#{document.created_at.to_date}\" } " }

          it { expect(edges).to eq([{ "node" => { "id" => other_document.id.to_s } }]) }
        end
      end

      context "with unpublished" do
        let!(:third_document) { create(:collaborative_text_document, created_at: 2.weeks.ago, updated_at: 1.week.ago, component: current_component) }
        let(:criteria) { "order: { id: \"asc\" }" }

        context "when not admin" do
          it {
            expect(edges).to eq([
                                  { "node" => { "id" => document.id.to_s } },
                                  { "node" => { "id" => other_document.id.to_s } }
                                ])
          }
        end

        context "with admin user" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization:) }
          let(:organization) { create(:organization) }

          it {
            expect(edges).to eq([
                                  { "node" => { "id" => document.id.to_s } },
                                  { "node" => { "id" => other_document.id.to_s } },
                                  { "node" => { "id" => third_document.id.to_s } }
                                ])
          }
        end
      end
    end
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["collaborativeText"]).to eq(document_single_result) }
  end

  include_examples "with resource visibility" do
    let(:component_factory) { :collaborative_text_component }
    let(:lookout_key) { "collaborativeText" }
    let(:query_result) { document_single_result }
  end
end
