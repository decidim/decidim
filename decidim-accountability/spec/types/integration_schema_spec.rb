# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/accountability/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"
  let(:component_type) { "Accountability" }
  let!(:current_component) { create :accountability_component, participatory_space: participatory_process }
  let!(:result) { create(:result, component: current_component, category: category) }
  let!(:timeline_entry) { create(:timeline_entry, result: result) }

  let(:accountability_single_result) do
    {
      "acceptsNewComments" => result.accepts_new_comments?,
      "category" => {
        "id" => result.category.id.to_s,
        "name" => { "translation" => result.category.name[locale] },
        "parent" => nil,
        "subcategories" => []
      },
      "children" => [],
      "childrenCount" => result.children.size,
      "comments" => [],
      "commentsHaveAlignment" => result.comments_have_alignment?,
      "commentsHaveVotes" => result.comments_have_votes?,
      "createdAt" => result.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => result.description[locale] },
      "endDate" => result.end_date.to_s,
      "externalId" => result.external_id,
      "hasComments" => result.comment_threads.size.positive?,
      "id" => result.id.to_s,
      "parent" => result.parent,
      "participatorySpace" => { "id" => result.participatory_space.id.to_s },
      "progress" => result.progress.to_f,
      "reference" => result.reference,
      "scope" => result.scope,
      "startDate" => result.start_date.to_s,
      "status" => {
        "createdAt" => result.status.created_at.to_date.to_s,
        "description" => { "translation" => result.status.description[locale] },
        "id" => result.status.id.to_s,
        "key" => result.status.key,
        "name" => { "translation" => result.status.name[locale] },
        "progress" => result.status.progress,
        "results" => [{ "id" => result.id.to_s }],
        "updatedAt" => result.status.updated_at.to_date.to_s
      },
      "timelineEntries" => [
        {
          "createdAt" => result.timeline_entries.first.created_at.iso8601.to_s.gsub("Z", "+00:00"),
          "title" => { "translation" => result.timeline_entries.first.title[locale] },
          "description" => { "translation" => result.timeline_entries.first.description[locale] },
          "entryDate" => result.timeline_entries.first.entry_date.to_s,
          "id" => result.timeline_entries.first.id.to_s,
          "result" => { "id" => result.id.to_s },
          "updatedAt" => result.timeline_entries.first.updated_at.iso8601.to_s.gsub("Z", "+00:00")
        }
      ],
      "title" => { "translation" => result.title[locale] },
      "totalCommentsCount" => result.comments_count,
      "type" => "Decidim::Accountability::Result",
      "updatedAt" => result.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "userAllowedToComment" => result.user_allowed_to_comment?(current_user),
      "weight" => result.weight.to_i
    }
  end

  let(:accountability_data) do
    {
      "__typename" => "Accountability",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Accountability" },
      "results" => {
        "edges" => [
          {
            "node" => accountability_single_result
          }
        ]
      },
      "weight" => 0
    }
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Accountability {
        results {
          edges{
            node{
              acceptsNewComments
              category {
                id
                name {
                  translation(locale: "#{locale}")
                }
                parent {
                  id
                }
                subcategories {
                  id
                }
              }
              children {
                id
              }
              childrenCount
              comments {
                id
              }
              commentsHaveAlignment
              commentsHaveVotes
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
              participatorySpace {
                id
              }
              progress
              reference
              scope {
                id
                children {
                  id
                }
                name {
                  translation(locale:"#{locale}")
                }
                parent {
                  id
                }
              }
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
              userAllowedToComment
              weight
            }
          }
        }
      }
    )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first).to eq(accountability_data) }
  end

  describe "valid query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Accountability {
        result(id: #{result.id}) {
          acceptsNewComments
          category {
            id
            name {
              translation(locale: "#{locale}")
            }
            parent {
              id
            }
            subcategories {
              id
            }
          }
          children {
            id
          }
          childrenCount
          comments {
            id
          }
          commentsHaveAlignment
          commentsHaveVotes
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
          participatorySpace {
            id
          }
          progress
          reference
          scope {
            id
            children {
              id
            }
            name {
              translation(locale:"#{locale}")
            }
            parent {
              id
            }
          }
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
          userAllowedToComment
          weight
        }
      }
    )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["result"]).to eq(accountability_single_result) }
  end
end
