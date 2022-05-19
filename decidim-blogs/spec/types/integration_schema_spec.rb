# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/accountability/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"
  let(:component_type) { "Blogs" }
  let!(:current_component) { create(:post_component, participatory_space: participatory_process) }
  let!(:post) { create(:post, :with_endorsements, component: current_component) }

  let(:post_single_result) do
    {
      "acceptsNewComments" => true,
      "attachments" => [],
      "author" => { "id" => post.author.id.to_s },
      "body" => { "translation" => post.body[locale] },
      "comments" => [],
      "commentsHaveAlignment" => true,
      "commentsHaveVotes" => true,
      "createdAt" => post.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "endorsements" => post.endorsements.map do |endo|
        {
          "__typename" => "User",
          "avatarUrl" => endo.author.attached_uploader(:avatar).path(variant: :thumb),
          "badge" => "",
          "deleted" => false,
          "id" => endo.author.id.to_s,
          "name" => endo.author.name,
          "nickname" => "@#{endo.author.nickname}",
          "organizationName" => endo.author.organization.name,
          "profilePath" => "/profiles/#{endo.author.nickname}"
        }
      end,
      "endorsementsCount" => 5,
      "hasComments" => false,
      "id" => post.id.to_s,
      "title" => { "translation" => post.title[locale] },
      "totalCommentsCount" => 0,
      "type" => "Decidim::Blogs::Post",
      "updatedAt" => post.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "userAllowedToComment" => true,
      "versions" => [],
      "versionsCount" => 0
    }
  end

  let(:posts_data) do
    {
      "__typename" => "Blogs",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Blog" },
      "posts" => {
        "edges" => [
          {
            "node" => post_single_result
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
      fragment fooComponent on Blogs {
        posts{
          edges {
            node{
              acceptsNewComments
              attachments {
                thumbnail
              }
              author {
                id
              }
              body {
                translation(locale:"#{locale}")
              }
              comments {
                id
              }
              commentsHaveAlignment
              commentsHaveVotes
              createdAt
              endorsements {
                id
                avatarUrl
                badge
                deleted
                name
                nickname
                organizationName
                profilePath
                __typename
              }
              endorsementsCount
              hasComments
              id
              title {
                translation(locale:"#{locale}")
              }
              totalCommentsCount
              type
              updatedAt
              userAllowedToComment
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
      it "executes sucessfully" do
        expect { response }.not_to raise_error
      end

      it { expect(response["participatoryProcess"]["components"].first).to eq(posts_data) }
    end

    context "with params" do
      let(:criteria) { { first: 1 } }

      let(:component_fragment) do
        %(
          fragment fooComponent on Blogs {
            posts(#{criteria}){
              edges {
                node{ id }
              }
            }
          }
        )
      end

      let!(:other_post) { create(:post, created_at: 2.weeks.ago, updated_at: 1.week.ago, component: current_component) }
      let(:edges) { response["participatoryProcess"]["components"].first["posts"]["edges"] }

      context "when ordered by" do
        context "with createdAt" do
          let(:criteria) { "order: { createdAt: \"asc\" }" }

          it {
            expect(edges).to eq([
                                  { "node" => { "id" => other_post.id.to_s } },
                                  { "node" => { "id" => post.id.to_s } }
                                ])
          }
        end

        context "with updatedAt" do
          let(:criteria) { "order: { updatedAt: \"asc\" }" }

          it {
            expect(edges).to eq([
                                  { "node" => { "id" => other_post.id.to_s } },
                                  { "node" => { "id" => post.id.to_s } }
                                ])
          }
        end

        context "with id" do
          let(:criteria) { "order: { id: \"asc\" }" }

          it {
            expect(edges).to eq([
                                  { "node" => { "id" => post.id.to_s } },
                                  { "node" => { "id" => other_post.id.to_s } }
                                ])
          }
        end

        context "with endorsementCount" do
          let(:criteria) { "order: { endorsementCount: \"asc\" }" }

          it { expect(edges).to eq([{ "node" => { "id" => other_post.id.to_s } }, { "node" => { "id" => post.id.to_s } }]) }
        end
      end

      context "when filtered by" do
        context "with createdBefore" do
          let(:criteria) { "filter: { createdBefore: \"#{1.week.ago.to_date}\" } " }

          it { expect(edges).to eq([{ "node" => { "id" => other_post.id.to_s } }]) }
        end

        context "with createdSince" do
          let(:criteria) { "filter: { createdSince: \"#{1.week.ago.to_date}\" } " }

          it { expect(edges).to eq([{ "node" => { "id" => post.id.to_s } }]) }
        end

        context "with updatedBefore" do
          let(:criteria) { "filter: { updatedBefore: \"#{post.created_at.to_date}\" } " }

          it { expect(edges).to eq([{ "node" => { "id" => other_post.id.to_s } }]) }
        end
      end
    end
  end

  describe "valid query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Blogs {
        post(id: #{post.id}) {
          acceptsNewComments
          attachments {
            thumbnail
          }
          author {
            id
          }
          body {
            translation(locale:"#{locale}")
          }
          comments {
            id
          }
          commentsHaveAlignment
          commentsHaveVotes
          createdAt
          endorsements {
            id
            avatarUrl
            badge
            deleted
            name
            nickname
            organizationName
            profilePath
            __typename
          }
          endorsementsCount
          hasComments
          id
          title {
            translation(locale:"#{locale}")
          }
          totalCommentsCount
          type
          updatedAt
          userAllowedToComment
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

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["post"]).to eq(post_single_result) }
  end
end
