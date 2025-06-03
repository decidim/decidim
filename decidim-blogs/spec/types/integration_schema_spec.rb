# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component" do
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
          likes {
            id
            avatarUrl
            badge
            deleted
            name
            nickname
            organizationName { translation(locale:"#{locale}") }
            profilePath
            __typename
          }
          likesCount
          followsCount
          hasComments
          id
          title {
            translation(locale:"#{locale}")
          }
          totalCommentsCount
          type
          updatedAt
          url
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
  end
  let(:component_type) { "Blogs" }
  let!(:current_component) { create(:post_component, participatory_space: participatory_process) }
  let!(:post) { create(:post, :with_likes, component: current_component, published_at: 2.days.ago) }
  let!(:follows) { create_list(:follow, 3, followable: post) }

  let(:post_single_result) do
    {
      "acceptsNewComments" => true,
      "attachments" => [],
      "author" => { "id" => post.author.id.to_s },
      "body" => { "translation" => post.body[locale] },
      "comments" => [],
      "commentsHaveAlignment" => true,
      "commentsHaveVotes" => true,
      "createdAt" => post.created_at.to_time.iso8601,
      "likes" => post.likes.map do |endo|
        {
          "__typename" => "User",
          "avatarUrl" => endo.author.attached_uploader(:avatar).variant_url(:thumb),
          "badge" => "",
          "deleted" => false,
          "id" => endo.author.id.to_s,
          "name" => endo.author.name,
          "nickname" => "@#{endo.author.nickname}",
          "organizationName" => { "translation" => translated(endo.author.organization.name) },
          "profilePath" => "/profiles/#{endo.author.nickname}"
        }
      end,
      "likesCount" => 5,
      "followsCount" => 3,
      "hasComments" => false,
      "id" => post.id.to_s,
      "title" => { "translation" => post.title[locale] },
      "totalCommentsCount" => 0,
      "type" => "Decidim::Blogs::Post",
      "updatedAt" => post.updated_at.to_time.iso8601,
      "url" => Decidim::ResourceLocatorPresenter.new(post).url,
      "userAllowedToComment" => post.user_allowed_to_comment?(current_user),
      "versions" => [],
      "versionsCount" => 0
    }
  end

  let(:posts_data) do
    {
      "__typename" => "Blogs",
      "id" => current_component.id.to_s,
      "name" => { "translation" => translated(current_component.name) },
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
      "url" => Decidim::EngineRouter.main_proxy(current_component).root_url,
      "weight" => 0
    }
  end

  describe "commentable" do
    let(:component_fragment) { nil }

    let(:participatory_process_query) do
      %(
        commentable(id: "#{post.id}", type: "Decidim::Blogs::Post", locale: "en", toggleTranslations: false) {
          __typename
        }
      )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response).to eq({ "commentable" => { "__typename" => "Post" } })
    end
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
              likes {
                id
                avatarUrl
                badge
                deleted
                name
                nickname
                organizationName { translation(locale:"#{locale}") }
                profilePath
                __typename
              }
              likesCount
              followsCount
              hasComments
              id
              title {
                translation(locale:"#{locale}")
              }
              totalCommentsCount
              type
              updatedAt
              url
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
      it "executes successfully" do
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

      let!(:other_post) { create(:post, created_at: 2.weeks.ago, updated_at: 1.week.ago, component: current_component, published_at: 2.weeks.ago) }
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

        context "with likeCount" do
          let(:criteria) { "order: { likeCount: \"asc\" }" }

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

      context "with unpublished" do
        let!(:third_post) { create(:post, created_at: 2.weeks.ago, updated_at: 1.week.ago, component: current_component, published_at: 2.weeks.from_now) }
        let(:criteria) { "order: { id: \"asc\" }" }

        context "when not admin" do
          it {
            expect(edges).to eq([
                                  { "node" => { "id" => post.id.to_s } },
                                  { "node" => { "id" => other_post.id.to_s } }
                                ])
          }
        end

        context "with admin user" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization:) }
          let(:organization) { create(:organization) }

          it {
            expect(edges).to eq([
                                  { "node" => { "id" => post.id.to_s } },
                                  { "node" => { "id" => other_post.id.to_s } },
                                  { "node" => { "id" => third_post.id.to_s } }
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

    it { expect(response["participatoryProcess"]["components"].first["post"]).to eq(post_single_result) }
  end

  include_examples "with resource visibility" do
    let(:component_factory) { :post_component }
    let(:lookout_key) { "post" }
    let(:query_result) { post_single_result }
  end
end
