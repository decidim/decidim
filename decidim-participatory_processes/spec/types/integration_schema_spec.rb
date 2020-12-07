# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:pp) { create(:participatory_process, organization: current_organization) }

  let(:participatoryProcess) do
    %(
      participatoryProcess {
        announcement{
          translation(locale: "#{locale}")
          locales
        }
        attachments{
          url
          type
          thumbnail
        }
        bannerImage
        categories{
          id
          name{
            translation(locale: "#{locale}")
          }
          parent {
            id
          }
          subcategories{
            id
          }
        }
        components{
          id
          name {
            translation(locale: "#{locale}")
          }
          weight
          __typename
        }

        createdAt
        description {
            translation(locale: "#{locale}")
          }
        developerGroup{
            translation(locale: "#{locale}")
          }
        endDate
        hashtag
        heroImage
        id
        linkedParticipatorySpaces{
          fromType
          id
          name
          participatorySpace{
            id
          }
          toType
        }
        localArea {
            translation(locale: "#{locale}")
          }
        metaScope {
            translation(locale: "#{locale}")
          }
        participatoryProcessGroup {
          description {
            translation(locale: "#{locale}")
          }
          heroImage
          id
          title{
            translation(locale: "#{locale}")
          }
          participatoryProcesses {
            id
          }
        }
        participatoryScope {
            translation(locale: "#{locale}")
          }
        participatoryStructure {
            translation(locale: "#{locale}")
          }
        promoted
        publishedAt
        reference
        scope {
          children {
            id
          }
          id
          name {
            translation(locale: "#{locale}")
          }
          parent {
            id
          }
        }
        scopesEnabled
        shortDescription {
            translation(locale: "#{locale}")
          }
        showMetrics
        showStatistics
        slug
        startDate
        stats {
          name
          value
        }
        steps {
          active
          callToActionPath
          callToActionText{
            translation(locale: "#{locale}")
          }
          description{
            translation(locale: "#{locale}")
          }
          endDate
          id
          participatoryProcess {
            id
          }
          position
          startDate
          title {
            translation(locale: "#{locale}")
          }
        }
        subtitle {
            translation(locale: "#{locale}")
          }
        target{
            translation(locale: "#{locale}")
          }
        title{
            translation(locale: "#{locale}")
          }
        type
        updatedAt
      }
    )
  end

  let(:pp_components) { [] }
  let!(:pp_data) do
    {
      "announcement" => {
        "locales" => pp.announcement.keys.sort,
        "translation" => pp.announcement[locale]
      },
      "attachments" => [],
      "bannerImage" => pp.banner_image.path.sub(Rails.root.join("public").to_s, ""),
      "categories" => [],
      "components" => pp_components,
      "createdAt" => pp.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => pp.description[locale] },
      "developerGroup" => { "translation" => pp.developer_group[locale] },
      "endDate" => pp.end_date.to_s,
      "hashtag" => "",
      "heroImage" => pp.hero_image.path.sub(Rails.root.join("public").to_s, ""),
      "id" => pp.id.to_s,
      "linkedParticipatorySpaces" => [],
      "localArea" => { "translation" => pp.local_area[locale] },
      "metaScope" => { "translation" => pp.meta_scope[locale] },
      "participatoryProcessGroup" => nil,
      "participatoryScope" => { "translation" => pp.participatory_scope[locale] },
      "participatoryStructure" => { "translation" => pp.participatory_structure[locale] },
      "promoted" => false,
      "publishedAt" => pp.published_at.iso8601.to_s.gsub("Z", "+00:00"),
      "reference" => pp.reference,
      "scope" => pp.scope,
      "scopesEnabled" => pp.scopes_enabled,
      "shortDescription" => { "translation" => pp.short_description[locale] },
      "showMetrics" => pp.show_metrics,
      "showStatistics" => pp.show_statistics,
      "slug" => pp.slug,
      "startDate" => pp.start_date.to_s,
      "steps" => pp.steps.to_a,
      "subtitle" => { "translation" => pp.subtitle[locale] },
      "target" => { "translation" => pp.target[locale] },
      "title" => { "translation" => pp.title[locale] },
      "type" => "Decidim::ParticipatoryProcess",
      "updatedAt" => pp.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "stats" => [
        { "name" => "dummies_count_high", "value" => 0 },
        { "name" => "pages_count", "value" => 0 },
        { "name" => "meetings_count", "value" => 0 },
        { "name" => "proposals_count", "value" => 0 },
        { "name" => "budgets_count", "value" => 0 },
        { "name" => "surveys_count", "value" => 0 },
        { "name" => "results_count", "value" => 0 },
        { "name" => "debates_count", "value" => 0 },
        { "name" => "sortitions_count", "value" => 0 },
        { "name" => "posts_count", "value" => 0 },
        { "name" => "elections_count", "value" => 0 }
      ]
    }
  end
  let(:query) do
    %(
      query {
        #{participatoryProcess}
      }
    )
  end

  describe "valid query" do
    it "executes sucessfully" do
      expect { response }.not_to raise_error(StandardError)
    end

    it "" do
      expect(response["participatoryProcess"]).to eq(pp_data)
    end
  end
end
