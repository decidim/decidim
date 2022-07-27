# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:participatory_process) { create(:participatory_process, organization: current_organization) }

  let(:participatory_process_query) do
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

  let(:components) { [] }
  let!(:participatory_process_response) do
    {
      "announcement" => {
        "locales" => participatory_process.announcement.keys.sort,
        "translation" => participatory_process.announcement[locale]
      },
      "attachments" => [],
      "bannerImage" => participatory_process.attached_uploader(:banner_image).path.sub(Rails.public_path.to_s, ""),
      "categories" => [],
      "components" => components,
      "createdAt" => participatory_process.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => participatory_process.description[locale] },
      "developerGroup" => { "translation" => participatory_process.developer_group[locale] },
      "endDate" => participatory_process.end_date.to_s,
      "hashtag" => "",
      "heroImage" => participatory_process.attached_uploader(:hero_image).path.sub(Rails.public_path.to_s, ""),
      "id" => participatory_process.id.to_s,
      "linkedParticipatorySpaces" => [],
      "localArea" => { "translation" => participatory_process.local_area[locale] },
      "metaScope" => { "translation" => participatory_process.meta_scope[locale] },
      "participatoryProcessGroup" => nil,
      "participatoryScope" => { "translation" => participatory_process.participatory_scope[locale] },
      "participatoryStructure" => { "translation" => participatory_process.participatory_structure[locale] },
      "promoted" => false,
      "publishedAt" => participatory_process.published_at.iso8601.to_s.gsub("Z", "+00:00"),
      "reference" => participatory_process.reference,
      "scope" => participatory_process.scope,
      "scopesEnabled" => participatory_process.scopes_enabled,
      "shortDescription" => { "translation" => participatory_process.short_description[locale] },
      "showMetrics" => participatory_process.show_metrics,
      "showStatistics" => participatory_process.show_statistics,
      "slug" => participatory_process.slug,
      "startDate" => participatory_process.start_date.to_s,
      "steps" => participatory_process.steps.to_a,
      "subtitle" => { "translation" => participatory_process.subtitle[locale] },
      "target" => { "translation" => participatory_process.target[locale] },
      "title" => { "translation" => participatory_process.title[locale] },
      "type" => "Decidim::ParticipatoryProcess",
      "updatedAt" => participatory_process.updated_at.iso8601.to_s.gsub("Z", "+00:00")
    }
  end
  let(:query) do
    %(
      query {
        #{participatory_process_query}
      }
    )
  end

  describe "valid query" do
    it "executes sucessfully" do
      expect { response }.not_to raise_error(StandardError)
    end

    it { expect(response["participatoryProcess"]).to eq(participatory_process_response) }

    it_behaves_like "implements stats type" do
      let(:participatory_process_query) do
        %(
          participatoryProcess{
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["participatoryProcess"]["stats"] }
    end

    context "with private spaces" do
      let!(:participatory_process2) { create(:participatory_process, organization: current_organization) }
      let!(:participatory_process3) { create(:participatory_process, organization: current_organization) }
      let!(:private_process) { create(:participatory_process, :private, organization: current_organization) }

      let(:participatory_process_query) { "participatoryProcesses { id }" }

      it "returns only the public spaces for normal participants" do
        expect(response["participatoryProcesses"]).to include(
          { "id" => participatory_process.id.to_s },
          { "id" => participatory_process2.id.to_s },
          { "id" => participatory_process3.id.to_s }
        )
        expect(response["participatoryProcesses"]).not_to include(
          { "id" => private_process.id.to_s }
        )
      end

      context "when the user is not logged in" do
        let!(:current_user) { nil }

        it "returns only the public spaces by default" do
          expect(response["participatoryProcesses"]).to include(
            { "id" => participatory_process.id.to_s },
            { "id" => participatory_process2.id.to_s },
            { "id" => participatory_process3.id.to_s }
          )
          expect(response["participatoryProcesses"]).not_to include(
            { "id" => private_process.id.to_s }
          )
        end
      end

      context "when the current user is an admin" do
        let!(:current_user) { create(:user, :admin, organization: current_organization) }

        it "returns all spaces" do
          expect(response["participatoryProcesses"]).to include(
            { "id" => participatory_process.id.to_s },
            { "id" => participatory_process2.id.to_s },
            { "id" => participatory_process3.id.to_s },
            { "id" => private_process.id.to_s }
          )
        end
      end

      context "when the current user is a private participant" do
        let!(:private_user) { create(:participatory_space_private_user, privatable_to: private_process, user: current_user) }

        it "returns all spaces" do
          expect(response["participatoryProcesses"]).to include(
            { "id" => participatory_process.id.to_s },
            { "id" => participatory_process2.id.to_s },
            { "id" => participatory_process3.id.to_s },
            { "id" => private_process.id.to_s }
          )
        end
      end
    end
  end
end
