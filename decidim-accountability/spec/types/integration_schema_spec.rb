# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Accountability {
        result(id: #{result.id}) {
          acceptsNewComments
          address
          children {
            id
          }
          childrenCount
          comments {
            id
          }
          commentsHaveAlignment
          commentsHaveVotes
          coordinates{
            latitude
            longitude
          }
          createdAt
          description {
            translation(locale:"#{locale}")
          }
          endDate
          externalId
          hasComments
          id
          parent {
            id
          }
          progress
          proposals { id }
          reference
          startDate
          status {
            id
            createdAt
            description {
              translation(locale:"#{locale}")
            }
            key
            name {
              translation(locale:"#{locale}")
            }
            progress
            results {
              id
            }
            updatedAt
          }
          taxonomies {
            id
          }
          timelineEntries {
            id
            createdAt
            title {
              translation(locale:"#{locale}")
            }
            description {
              translation(locale:"#{locale}")
            }
            entryDate
            result {
              id
            }
            updatedAt
          }
          title {
            translation(locale:"#{locale}")
          }
          totalCommentsCount
          type
          updatedAt
          url
          userAllowedToComment
          weight
        }
      }
    )
    end
  end
  let(:component_type) { "Accountability" }
  let(:accountability_single_result) do
    {
      "acceptsNewComments" => result.accepts_new_comments?,
      "address" => result.address.to_s,
      "children" => [],
      "childrenCount" => result.children.size,
      "comments" => [],
      "commentsHaveAlignment" => result.comments_have_alignment?,
      "commentsHaveVotes" => result.comments_have_votes?,
      "coordinates" => {
        "latitude" => result.latitude,
        "longitude" => result.longitude
      },
      "createdAt" => result.created_at.to_time.iso8601,
      "description" => { "translation" => result.description[locale] },
      "endDate" => result.end_date.to_s,
      "externalId" => result.external_id,
      "hasComments" => result.comment_threads.size.positive?,
      "id" => result.id.to_s,
      "parent" => result.parent,
      "progress" => result.progress.to_f,
      "proposals" => proposals.sort_by(&:id).map { |proposal| { "id" => proposal.id.to_s } },
      "reference" => result.reference,
      "startDate" => result.start_date.to_s,
      "status" => {
        "createdAt" => result.status.created_at.to_time.iso8601,
        "description" => { "translation" => result.status.description[locale] },
        "id" => result.status.id.to_s,
        "key" => result.status.key,
        "name" => { "translation" => result.status.name[locale] },
        "progress" => result.status.progress,
        "results" => [{ "id" => result.id.to_s }],
        "updatedAt" => result.status.updated_at.to_time.iso8601
      },
      "taxonomies" => [{ "id" => result.taxonomies.first.id.to_s }],
      "timelineEntries" => [
        {
          "createdAt" => result.timeline_entries.first.created_at.to_time.iso8601,
          "title" => { "translation" => result.timeline_entries.first.title[locale] },
          "description" => { "translation" => result.timeline_entries.first.description[locale] },
          "entryDate" => result.timeline_entries.first.entry_date.to_s,
          "id" => result.timeline_entries.first.id.to_s,
          "result" => { "id" => result.id.to_s },
          "updatedAt" => result.timeline_entries.first.updated_at.to_time.iso8601
        }
      ],
      "title" => { "translation" => result.title[locale] },
      "totalCommentsCount" => result.comments_count,
      "type" => "Decidim::Accountability::Result",
      "url" => Decidim::ResourceLocatorPresenter.new(result).url,
      "updatedAt" => result.updated_at.to_time.iso8601,
      "userAllowedToComment" => result.user_allowed_to_comment?(current_user),
      "weight" => result.weight.to_i
    }
  end
  let(:accountability_data) do
    {
      "__typename" => "Accountability",
      "id" => current_component.id.to_s,
      "name" => { "translation" => translated(current_component.name) },
      "results" => {
        "edges" => [
          {
            "node" => accountability_single_result
          }
        ]
      },
      "url" => Decidim::EngineRouter.main_proxy(current_component).root_url,
      "weight" => 0
    }
  end
  let!(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
  let!(:result) { create(:result, component: current_component, taxonomies:) }
  let!(:timeline_entry) { create(:timeline_entry, result:) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: result.participatory_space) }
  let(:proposals) { create_list(:proposal, rand(20), :published, component: proposal_component) }

  before do
    result.link_resources(proposals, "included_proposals")
  end

  describe "commentable" do
    let(:component_fragment) { nil }

    let(:participatory_process_query) do
      %(
        commentable(id: "#{result.id}", type: "Decidim::Accountability::Result", locale: "en", toggleTranslations: false) {
          __typename
        }
      )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response).to eq({ "commentable" => { "__typename" => "Result" } })
    end
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Accountability {
        results {
          edges{
            node{
              acceptsNewComments
              address
              children {
                id
              }
              childrenCount
              comments {
                id
              }
              commentsHaveAlignment
              commentsHaveVotes
              coordinates{
                latitude
                longitude
              }
              createdAt
              description {
                translation(locale:"#{locale}")
              }
              endDate
              externalId
              hasComments
              id
              parent {
                id
              }
              progress
              proposals { id }
              reference
              startDate
              status {
                id
                createdAt
                description {
                  translation(locale:"#{locale}")
                }
                key
                name {
                  translation(locale:"#{locale}")
                }
                progress
                results {
                  id
                }
                updatedAt
              }
              taxonomies {
                id
              }
              timelineEntries {
                id
                createdAt
                title {
                  translation(locale:"#{locale}")
                }
                description {
                  translation(locale:"#{locale}")
                }
                entryDate
                result {
                  id
                }
                updatedAt
              }
              title {
                translation(locale:"#{locale}")
              }
              totalCommentsCount
              type
              updatedAt
              url
              userAllowedToComment
              weight
            }
          }
        }
      }
    )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first).to eq(accountability_data) }
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["result"]).to eq(accountability_single_result) }
  end

  include_examples "with resource visibility" do
    let(:component_factory) { :accountability_component }
    let(:lookout_key) { "result" }
    let(:query_result) { accountability_single_result }
  end
end
