# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/initiatives/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }
  let!(:initiative) { create(:initiative, organization: current_organization) }

  let(:initiative_data) do
    {
      "attachments" => [],
      "author" => { "id" => initiative.author.id.to_s },
      "committeeMembers" => initiative.committee_members.map do |cm|
        {
          "createdAt" => cm.created_at.iso8601.to_s.gsub("Z", "+00:00"),
          "id" => cm.id.to_s,
          "state" => cm.state,
          "updatedAt" => cm.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
          "user" => { "id" => cm.decidim_users_id.to_s }
        }
      end,
      "components" => [],
      "createdAt" => initiative.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => initiative.description[locale] },
      "hashtag" => initiative.hashtag,
      "id" => initiative.id.to_s,
      "initiativeType" => {
        "bannerImage" => initiative.type.attached_uploader(:banner_image).path,
        "collectUserExtraFields" => initiative.type.collect_user_extra_fields?,
        "createdAt" => initiative.type.created_at.iso8601.to_s.gsub("Z", "+00:00"),
        "description" => { "translation" => initiative.type.description[locale] },
        "extraFieldsLegalInformation" => initiative.type.extra_fields_legal_information,
        "id" => initiative.type.id.to_s,
        "initiatives" => initiative.type.initiatives.map { |i| { "id" => i.id.to_s } },
        "minimumCommitteeMembers" => initiative.type.minimum_committee_members,
        "promotingCommitteeEnabled" => initiative.type.promoting_committee_enabled,
        "signatureType" => initiative.type.signature_type,
        "title" => { "translation" => initiative.type.title[locale] },
        "undoOnlineSignaturesEnabled" => initiative.type.undo_online_signatures_enabled,
        "updatedAt" => initiative.type.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
        "validateSmsCodeOnVotes" => initiative.type.validate_sms_code_on_votes
      },
      "offlineVotes" => initiative.offline_votes_count,
      "onlineVotes" => initiative.online_votes_count,
      "publishedAt" => initiative.published_at.iso8601.to_s.gsub("Z", "+00:00"),
      "reference" => initiative.reference,
      "scope" => { "id" => initiative.scope.id.to_s },
      "signatureEndDate" => initiative.signature_end_date.to_date.to_s,
      "signatureStartDate" => initiative.signature_start_date.to_date.to_s,
      "signatureType" => initiative.signature_type,
      "slug" => initiative.slug,
      "state" => initiative.state,
      "title" => { "translation" => initiative.title[locale] },
      "type" => initiative.class.name,
      "updatedAt" => initiative.updated_at.iso8601.to_s.gsub("Z", "+00:00")

    }
  end

  let(:initiatives) do
    %(
      initiatives{
        attachments {
          thumbnail
        }
        author {
          id
        }
        committeeMembers {
          createdAt
          id
          state
          updatedAt
          user { id }
        }
        components {
          id
        }
        createdAt
        description {
          translation(locale: "#{locale}")
        }
        hashtag
        id
        initiativeType {
          bannerImage
          collectUserExtraFields
          createdAt
          description {
          translation(locale: "#{locale}")
          }
          extraFieldsLegalInformation
          id
          initiatives{id}
          minimumCommitteeMembers
          promotingCommitteeEnabled
          signatureType
          title {
                  translation(locale: "#{locale}")

          }
          undoOnlineSignaturesEnabled
          updatedAt
          validateSmsCodeOnVotes
        }
        offlineVotes
        onlineVotes
        publishedAt
        reference
        scope {
          id
        }
        signatureEndDate
        signatureStartDate
        signatureType
        slug
        state
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
        #{initiatives}
      }
    )
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["initiatives"].first).to eq(initiative_data)
    end

    it_behaves_like "implements stats type" do
      let(:initiatives) do
        %(
          initiatives {
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["initiatives"].first["stats"] }
    end
  end

  describe "single assembly" do
    let(:initiatives) do
      %(
      initiative(id: #{initiative.id}){
        attachments {
          thumbnail
        }
        author {
          id
        }
        committeeMembers {
          createdAt
          id
          state
          updatedAt
          user { id }
        }
        components {
          id
        }
        createdAt
        description {
          translation(locale: "en")
        }
        hashtag
        id
        initiativeType {
          bannerImage
          collectUserExtraFields
          createdAt
          description {
          translation(locale: "en")
          }
          extraFieldsLegalInformation
          id
          initiatives{id}
          minimumCommitteeMembers
          promotingCommitteeEnabled
          signatureType
          title {
                  translation(locale: "en")

          }
          undoOnlineSignaturesEnabled
          updatedAt
          validateSmsCodeOnVotes
        }
        offlineVotes
        onlineVotes
        publishedAt
        reference
        scope {
          id
        }
        signatureEndDate
        signatureStartDate
        signatureType
        slug
        state
        title {
          translation(locale: "en")
        }
        type
        updatedAt
      }
    )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["initiative"]).to eq(initiative_data)
    end

    it_behaves_like "implements stats type" do
      let(:initiatives) do
        %(
          initiative(id: #{initiative.id}){
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["initiative"]["stats"] }
    end
  end
end
