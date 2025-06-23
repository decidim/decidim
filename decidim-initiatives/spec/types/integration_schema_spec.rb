# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "decidim/initiatives/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }
  let!(:initiative) do
    create(:initiative, organization: current_organization,
                        first_progress_notification_at: Time.current,
                        second_progress_notification_at: Time.current,
                        answered_at: Time.current,
                        answer: { en: "Measured answer" },
                        answer_url: "http://decidim.org")
  end

  let(:initiative_data) do
    {
      "answer" => { "translation" => initiative.answer[locale] },
      "answerUrl" => initiative.answer_url,
      "answeredAt" => initiative.answered_at.to_time.iso8601,
      "attachments" => [],
      "author" => { "id" => initiative.author.id.to_s },
      "committeeMembers" => initiative.committee_members.map do |cm|
        {
          "createdAt" => cm.created_at.to_time.iso8601,
          "id" => cm.id.to_s,
          "state" => cm.state,
          "updatedAt" => cm.updated_at.to_time.iso8601,
          "user" => { "id" => cm.decidim_users_id.to_s }
        }
      end,
      "components" => [],
      "createdAt" => initiative.created_at.to_time.iso8601,
      "description" => { "translation" => initiative.description[locale] },
      "firstProgressNotificationAt" => initiative.first_progress_notification_at.to_time.iso8601,
      "id" => initiative.id.to_s,
      "initiativeType" => initiative_type_data,
      "offlineVotes" => initiative.offline_votes_count,
      "onlineVotes" => initiative.online_votes_count,
      "publishedAt" => initiative.published_at.to_time.iso8601,
      "reference" => initiative.reference,
      "secondProgressNotificationAt" => initiative.second_progress_notification_at.to_time.iso8601,
      "scope" => { "id" => initiative.scope.id.to_s },
      "signatureEndDate" => initiative.signature_end_date.iso8601,
      "signatureStartDate" => initiative.signature_start_date.iso8601,
      "signatureType" => initiative.signature_type,
      "slug" => initiative.slug,
      "state" => initiative.state,
      "title" => { "translation" => initiative.title[locale] },
      "type" => initiative.class.name,
      "updatedAt" => initiative.updated_at.to_time.iso8601,
      "url" => Decidim::EngineRouter.main_proxy(initiative).initiative_url(initiative)
    }
  end
  let(:initiative_type_data) do
    {
      "attachmentsEnabled" => initiative.type.attachments_enabled,
      "collectUserExtraFields" => initiative.type.collect_user_extra_fields?,
      "commentsEnabled" => initiative.type.comments_enabled,
      "customSignatureEndDateEnabled" => initiative.type.custom_signature_end_date_enabled,
      "createdAt" => initiative.type.created_at.to_time.iso8601,
      "description" => { "translation" => initiative.type.description[locale] },
      "extraFieldsLegalInformation" => initiative.type.extra_fields_legal_information,
      "id" => initiative.type.id.to_s,
      "initiatives" => initiative.type.initiatives.map { |i| { "id" => i.id.to_s } },
      "minimumCommitteeMembers" => initiative.type.minimum_committee_members,
      "promotingCommitteeEnabled" => initiative.type.promoting_committee_enabled,
      "signatureType" => initiative.type.signature_type,
      "title" => { "translation" => initiative.type.title[locale] },
      "undoOnlineSignaturesEnabled" => initiative.type.undo_online_signatures_enabled,
      "updatedAt" => initiative.type.updated_at.to_time.iso8601,
      "validateSmsCodeOnVotes" => initiative.type.validate_sms_code_on_votes
    }
  end

  let(:initiatives) do
    %(
      initiatives{
        answer {
          translation(locale: "en")
        }
        answerUrl
        answeredAt
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
        firstProgressNotificationAt
        id
        initiativeType {
          attachmentsEnabled
          collectUserExtraFields
          commentsEnabled
          createdAt
          customSignatureEndDateEnabled
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
        secondProgressNotificationAt
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
        url
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
      data = response["initiatives"].first
      expect(data).to include(initiative_data)
      expect(data["initiativeType"]).to include(initiative_type_data)
    end

    it_behaves_like "implements stats type" do
      let(:initiatives) do
        %(
          initiatives {
            stats{
              name { translation(locale: "en") }
              value
            }
          }
        )
      end
      let(:stats_response) { response["initiatives"].first["stats"] }
    end
  end

  describe "single initiative" do
    let(:initiatives) do
      %(
      initiative(id: #{initiative.id}){
        answer {
          translation(locale: "en")
        }
        answerUrl
        answeredAt
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
        firstProgressNotificationAt
        id
        initiativeType {
          attachmentsEnabled
          collectUserExtraFields
          commentsEnabled
          createdAt
          customSignatureEndDateEnabled
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
        secondProgressNotificationAt
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
        url
      }
    )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      data = response["initiative"]
      expect(data).to include(initiative_data)
      expect(data["initiativeType"]).to include(initiative_type_data)
    end

    it_behaves_like "implements stats type" do
      let(:initiatives) do
        %(
          initiative(id: #{initiative.id}){
            stats{
              name { translation(locale: "en") }
              value
            }
          }
        )
      end
      let(:stats_response) { response["initiative"]["stats"] }
    end
  end
end
