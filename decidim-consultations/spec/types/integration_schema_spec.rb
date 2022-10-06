# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/consultations/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let!(:consultation) { create(:consultation, :finished, organization: current_organization) }
  let!(:question) { create(:question, consultation:) }

  let(:consultation_data) do
    {
      "bannerImage" => consultation.attached_uploader(:banner_image).path,
      "components" => [],
      "createdAt" => consultation.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => consultation.description[locale] },
      "endVotingDate" => consultation.end_voting_date.to_date.to_s,
      "highlightedScope" => { "id" => consultation.highlighted_scope.id.to_s },
      "id" => consultation.id.to_s,
      "introductoryImage" => consultation.attached_uploader(:introductory_image).path,
      "introductoryVideoUrl" => consultation.introductory_video_url,
      "publishedAt" => consultation.published_at.iso8601.to_s.gsub("Z", "+00:00"),
      "questions" => consultation.questions.map do |q|
        {
          "acceptsNewComments" => q.accepts_new_comments?,
          "attachments" => [],
          "bannerImage" => q.attached_uploader(:banner_image).path,
          "comments" => [],
          "commentsHaveAlignment" => q.comments_have_alignment?,
          "commentsHaveVotes" => q.comments_have_votes?,
          "components" => [],
          "createdAt" => q.created_at.iso8601.to_s.gsub("Z", "+00:00"),
          "externalVoting" => q.external_voting?,
          "hasComments" => q.comment_threads.size.positive?,
          "hashtag" => q.hashtag,
          "heroImage" => q.attached_uploader(:hero_image).path,
          "iFrameUrl" => q.i_frame_url,
          "id" => q.id.to_s,
          "instructions" => q.instructions,
          "maxVotes" => q.max_votes,
          "minVotes" => q.min_votes,
          "order" => q.order,
          "originScope" => q.origin_scope,
          "originTitle" => q.origin_title,
          "originUrl" => q.origin_url,
          "participatoryScope" => { "translation" => q.participatory_scope[locale] },
          "promoterGroup" => { "translation" => q.promoter_group[locale] },
          "publishedAt" => q.published_at.iso8601.to_s.gsub("Z", "+00:00"),
          "questionContext" => { "translation" => q.question_context[locale] },
          "reference" => q.reference,
          "responseGroupsCount" => q.response_groups_count,
          "responsesCount" => q.responses_count,
          "scope" => { "id" => q.scope.id.to_s },
          "slug" => q.slug,
          "subtitle" => { "translation" => q.subtitle[locale] },
          "title" => { "translation" => q.title[locale] },
          "totalCommentsCount" => q.comments_count,
          "type" => q.class.name,
          "updatedAt" => q.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
          "userAllowedToComment" => q.user_allowed_to_comment?(current_user),
          "votesCount" => q.votes.size,
          "whatIsDecided" => { "translation" => q.what_is_decided[locale] }
        }
      end,
      "resultsPublishedAt" => consultation.results_published_at,
      "slug" => consultation.slug,
      "startVotingDate" => consultation.start_voting_date.to_date.to_s,
      "subtitle" => { "translation" => consultation.subtitle[locale] },
      "title" => { "translation" => consultation.title[locale] },
      "type" => consultation.class.name,
      "updatedAt" => consultation.updated_at.iso8601.to_s.gsub("Z", "+00:00")

    }
  end

  let(:consultations) do
    %(
      consultations{
        bannerImage
        components {
          id
        }
        createdAt
        description {
          translation(locale: "#{locale}")
        }
        endVotingDate
        highlightedScope {
          id
        }
        id
        introductoryImage
        introductoryVideoUrl
        publishedAt
        questions {
          id
          acceptsNewComments
          attachments {
            thumbnail
          }
          bannerImage
          comments {
            id
          }
          commentsHaveAlignment
          commentsHaveVotes
          components {
            id
          }
          createdAt
          externalVoting
          hasComments
          hashtag
          heroImage
          iFrameUrl
          id
          instructions {
            translation(locale: "#{locale}")
          }
          maxVotes
          minVotes
          order
          originScope {
            translation(locale: "#{locale}")
          }
          originTitle {
            translation(locale: "#{locale}")
          }
          originUrl
          participatoryScope {
            translation(locale: "#{locale}")
          }
          promoterGroup {
            translation(locale: "#{locale}")
          }
          publishedAt
          questionContext {
            translation(locale: "#{locale}")
          }
          reference
          responsesCount
          responseGroupsCount
          scope {
            id
          }
          slug
          subtitle {
            translation(locale: "#{locale}")
          }
          title {
            translation(locale: "#{locale}")
          }
          totalCommentsCount
          type
          updatedAt
          userAllowedToComment
          votesCount
          whatIsDecided {
            translation(locale: "#{locale}")
          }
        }
        resultsPublishedAt
        slug
        startVotingDate
        subtitle {
          translation(locale: "#{locale}")
        }
        title {
          translation(locale: "#{locale}")
        }
        type
        updatedAt
      }
    )
  end

  let(:query) do
    %(
      query {
        #{consultations}
      }
    )
  end

  describe "valid query" do
    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["consultations"].first).to eq(consultation_data)
    end

    it_behaves_like "implements stats type" do
      let(:consultations) do
        %(
          consultations{
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["consultations"].first["stats"] }
    end
  end

  describe "single assembly" do
    let(:consultations) do
      %(
      consultation(id: #{consultation.id}){
        bannerImage
        components {
          id
        }
        createdAt
        description {
          translation(locale: "#{locale}")
        }
        endVotingDate
        highlightedScope {
          id
        }
        id
        introductoryImage
        introductoryVideoUrl
        publishedAt
        questions {
          id
          acceptsNewComments
          attachments {
            thumbnail
          }
          bannerImage
          comments {
            id
          }
          commentsHaveAlignment
          commentsHaveVotes
          components {
            id
          }
          createdAt
          externalVoting
          hasComments
          hashtag
          heroImage
          iFrameUrl
          id
          instructions {
            translation(locale: "#{locale}")
          }
          maxVotes
          minVotes
          order
          originScope {
            translation(locale: "#{locale}")
          }
          originTitle {
            translation(locale: "#{locale}")
          }
          originUrl
          participatoryScope {
            translation(locale: "#{locale}")
          }
          promoterGroup {
            translation(locale: "#{locale}")
          }
          publishedAt
          questionContext {
            translation(locale: "#{locale}")
          }
          reference
          responsesCount
          responseGroupsCount
          scope {
            id
          }
          slug
          subtitle {
            translation(locale: "#{locale}")
          }
          title {
            translation(locale: "#{locale}")
          }
          totalCommentsCount
          type
          updatedAt
          userAllowedToComment
          votesCount
          whatIsDecided {
            translation(locale: "#{locale}")
          }
        }
        resultsPublishedAt
        slug
        startVotingDate
        subtitle {
          translation(locale: "#{locale}")
        }
        title {
          translation(locale: "#{locale}")
        }
        type
        updatedAt
      }
    )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["consultation"]).to eq(consultation_data)
    end

    it_behaves_like "implements stats type" do
      let(:consultations) do
        %(
          consultation(id: #{consultation.id}){
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["consultation"]["stats"] }
    end
  end
end
