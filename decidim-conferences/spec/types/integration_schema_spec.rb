# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "decidim/conferences/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let!(:taxonomy) { create(:taxonomy, :with_parent, :with_children, organization: current_organization) }
  let!(:conference) { create(:conference, :diploma, organization: current_organization, taxonomies: [taxonomy]) }
  let!(:follows) { create_list(:follow, 3, followable: conference) }

  let(:conference_data) do
    {
      "attachments" => [],
      "availableSlots" => conference.available_slots,
      "categories" => [],
      "components" => [],
      "createdAt" => conference.created_at.to_time.iso8601,
      "description" => { "translation" => conference.description[locale] },
      "endDate" => conference.end_date.to_s,
      "followsCount" => 3,
      "hashtag" => conference.hashtag,
      "id" => conference.id.to_s,
      "location" => conference.location,
      "mediaLinks" => [],
      "objectives" => { "translation" => conference.objectives[locale] },
      "partners" => [],
      "promoted" => conference.promoted?,
      "publishedAt" => conference.published_at.to_time.iso8601,
      "reference" => conference.reference,
      "registrationTerms" => { "translation" => conference.registration_terms[locale] },
      "registrationsEnabled" => conference.registrations_enabled?,
      "taxonomies" => [{ "id" => taxonomy.id.to_s, "name" => { "translation" => taxonomy.name[locale] }, "parent" => { "id" => taxonomy.parent_id.to_s }, "children" => taxonomy.children.map { |child| { "id" => child.id.to_s } } }],
      "shortDescription" => { "translation" => conference.short_description[locale] },
      "showStatistics" => conference.show_statistics?,
      "slogan" => { "translation" => conference.slogan[locale] },
      "slug" => conference.slug,
      "speakers" => conference.speakers.map { |s| { "id" => s.id.to_s } },
      "startDate" => conference.start_date.iso8601,
      "title" => { "translation" => conference.title[locale] },
      "type" => conference.class.name,
      "updatedAt" => conference.updated_at.to_time.iso8601,
      "url" => Decidim::EngineRouter.main_proxy(conference).conference_url(conference),
      "weight" => conference.weight
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
        followsCount
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
        taxonomies {
          parent {
            id
          }
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
        url
        weight
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
      data = response["conferences"].first
      expect(data).to include(conference_data)
      expect(data["bannerImage"]).to be_blob_url(conference.banner_image.blob)
      expect(data["heroImage"]).to be_blob_url(conference.hero_image.blob)
    end

    it_behaves_like "implements stats type" do
      let(:conferences) do
        %(
          conferences {
            stats{
              name { translation(locale: "#{locale}") }
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
        followsCount
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
        taxonomies {
          parent {
            id
          }
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
        url
        weight
      }
    )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      data = response["conference"]
      expect(data).to include(conference_data)
      expect(data["bannerImage"]).to be_blob_url(conference.banner_image.blob)
      expect(data["heroImage"]).to be_blob_url(conference.hero_image.blob)
    end

    it_behaves_like "implements stats type" do
      let(:conferences) do
        %(
          conference(id: #{conference.id}){
            stats{
              name { translation(locale: "en") }
              value
            }
          }
        )
      end
      let(:stats_response) { response["conference"]["stats"] }
    end
  end
end
