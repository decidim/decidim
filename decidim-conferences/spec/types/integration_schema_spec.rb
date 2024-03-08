# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/conferences/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let!(:conference) { create(:conference, :diploma, organization: current_organization) }
  let(:conference_data) do
    {
      "attachments" => [],
      "availableSlots" => conference.available_slots,
      "bannerImage" => conference.attached_uploader(:banner_image).path,
      "categories" => [],
      "components" => [],
      "createdAt" => conference.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => conference.description[locale] },
      "endDate" => conference.end_date.to_s,
      "hashtag" => conference.hashtag,
      "heroImage" => conference.attached_uploader(:hero_image).path,
      "id" => conference.id.to_s,
      "location" => conference.location,
      "mediaLinks" => [],
      "objectives" => { "translation" => conference.objectives[locale] },
      "partners" => [],
      "promoted" => conference.promoted?,
      "publishedAt" => conference.published_at.iso8601.to_s.gsub("Z", "+00:00"),
      "reference" => conference.reference,
      "registrationTerms" => { "translation" => conference.registration_terms[locale] },
      "registrationsEnabled" => conference.registrations_enabled?,
      "scope" => nil,
      "shortDescription" => { "translation" => conference.short_description[locale] },
      "showStatistics" => conference.show_statistics?,
      "slogan" => { "translation" => conference.slogan[locale] },
      "slug" => conference.slug,
      "speakers" => conference.speakers.map { |s| { "id" => s.id.to_s } },
      "startDate" => conference.start_date.to_date.to_s,
      "title" => { "translation" => conference.title[locale] },
      "type" => conference.class.name,
      "updatedAt" => conference.updated_at.iso8601.to_s.gsub("Z", "+00:00")
    }
  end

  let(:conferences) do
    %(
      conferences {
        attachments {
          thumbnail
        }
        availableSlots
        bannerImage
        categories {
          id
        }
        components {
          id
        }
        createdAt
        description {
          translation(locale:"#{locale}")
        }
        endDate
        hashtag
        heroImage
        id
        location
        mediaLinks {
          id
        }
        objectives {
          translation(locale:"#{locale}")
        }
        partners {
          id
        }
        promoted
        publishedAt
        reference
        registrationTerms {
          translation(locale:"#{locale}")
        }
        registrationsEnabled
        scope {
          id
          children{
            id
          }
          name{
            translation(locale:"#{locale}")
          }
        }
        shortDescription {
          translation(locale:"#{locale}")
        }
        showStatistics
        slogan {
          translation(locale:"#{locale}")
        }
        slug
        speakers {
          id
        }
        startDate
        title {
          translation(locale:"#{locale}")
        }
        type
        updatedAt
      }
    )
  end

  let(:query) do
    %(
      query {
        #{conferences}
      }
    )
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["conferences"].first).to eq(conference_data)
    end

    it_behaves_like "implements stats type" do
      let(:conferences) do
        %(
          conferences {
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["conferences"].first["stats"] }
    end
  end

  describe "single assembly" do
    let(:conferences) do
      %(
      conference(id: #{conference.id}){
        attachments {
          thumbnail
        }
        availableSlots
        bannerImage
        categories {
          id
        }
        components {
          id
        }
        createdAt
        description {
          translation(locale:"#{locale}")
        }
        endDate
        hashtag
        heroImage
        id
        location
        mediaLinks {
          id
        }
        objectives {
          translation(locale:"#{locale}")
        }
        partners {
          id
        }
        promoted
        publishedAt
        reference
        registrationTerms {
          translation(locale:"#{locale}")
        }
        registrationsEnabled
        scope {
          id
          children{
            id
          }
          name{
            translation(locale:"#{locale}")
          }
        }
        shortDescription {
          translation(locale:"#{locale}")
        }
        showStatistics
        slogan {
          translation(locale:"#{locale}")
        }
        slug
        speakers {
          id
        }
        startDate
        title {
          translation(locale:"#{locale}")
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
      expect(response["conference"]).to eq(conference_data)
    end

    it_behaves_like "implements stats type" do
      let(:conferences) do
        %(
          conference(id: #{conference.id}){
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["conference"]["stats"] }
    end
  end
end
