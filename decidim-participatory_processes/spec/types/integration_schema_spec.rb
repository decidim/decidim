# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let!(:taxonomy) { create(:taxonomy, :with_parent, :with_children, organization: current_organization) }
  let!(:participatory_process_group) { create(:participatory_process_group, organization: current_organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: current_organization, participatory_process_group:, taxonomies: [taxonomy]) }
  let!(:follows) { create_list(:follow, 3, followable: participatory_process) }
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
        followsCount
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
          createdAt
          description {
            translation(locale: "#{locale}")
          }
          developerGroup{
            translation(locale: "#{locale}")
          }
          id
          localArea {
            translation(locale: "#{locale}")
          }
          metaScope{
            translation(locale: "#{locale}")
          }
          participatoryProcesses {
            id
          }
          participatoryScope {
            translation(locale: "#{locale}")
          }
          participatoryStructure {
            translation(locale: "#{locale}")
          }
          promoted
          target {
            translation(locale: "#{locale}")
          }
          title{
            translation(locale: "#{locale}")
          }
          updatedAt
        }
        participatoryScope {
          translation(locale: "#{locale}")
        }
        participatoryStructure {
          translation(locale: "#{locale}")
        }
        privateSpace
        promoted
        publishedAt
        reference
        taxonomies {
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
        shortDescription {
          translation(locale: "#{locale}")
        }
        slug
        startDate
        steps {
          active
          callToActionPath
          callToActionText{
            translation(locale: "#{locale}")
          }
          createdAt
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
          updatedAt
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
        url
        weight
      }
    )
  end

  let(:components) { [] }
  let!(:participatory_process_response) do
    {
      "announcement" => {
        "locales" => (
          participatory_process.announcement.keys.excluding("machine_translations") +
          participatory_process.announcement["machine_translations"].keys
        ).sort,
        "translation" => participatory_process.announcement[locale]
      },
      "attachments" => [],
      "categories" => [],
      "components" => components,
      "createdAt" => participatory_process.created_at.to_time.iso8601,
      "description" => { "translation" => participatory_process.description[locale] },
      "developerGroup" => { "translation" => participatory_process.developer_group[locale] },
      "endDate" => participatory_process.end_date.to_s,
      "followsCount" => 3,
      "id" => participatory_process.id.to_s,
      "linkedParticipatorySpaces" => [],
      "localArea" => { "translation" => participatory_process.local_area[locale] },
      "metaScope" => { "translation" => participatory_process.meta_scope[locale] },
      "participatoryProcessGroup" => {
        "createdAt" => participatory_process_group.created_at.to_time.iso8601,
        "description" => { "translation" => participatory_process_group.description[locale] },
        "developerGroup" => { "translation" => participatory_process_group.developer_group[locale] },
        "id" => participatory_process_group.id.to_s,
        "localArea" => { "translation" => participatory_process_group.local_area[locale] },
        "metaScope" => { "translation" => participatory_process_group.meta_scope[locale] },
        "participatoryProcesses" => [{ "id" => participatory_process.id.to_s }],
        "participatoryScope" => { "translation" => participatory_process_group.participatory_scope[locale] },
        "participatoryStructure" => { "translation" => participatory_process_group.participatory_structure[locale] },
        "promoted" => participatory_process_group.promoted,
        "target" => { "translation" => participatory_process_group.target[locale] },
        "title" => { "translation" => participatory_process_group.title[locale] },
        "updatedAt" => participatory_process_group.updated_at.to_time.iso8601
      },
      "participatoryScope" => { "translation" => participatory_process.participatory_scope[locale] },
      "participatoryStructure" => { "translation" => participatory_process.participatory_structure[locale] },
      "privateSpace" => participatory_process.private_space?,
      "promoted" => false,
      "publishedAt" => participatory_process.published_at.to_time.iso8601,
      "reference" => participatory_process.reference,
      "taxonomies" => [{ "id" => taxonomy.id.to_s, "name" => { "translation" => taxonomy.name[locale] }, "parent" => { "id" => taxonomy.parent_id.to_s }, "children" => taxonomy.children.map { |child| { "id" => child.id.to_s } } }],
      "shortDescription" => { "translation" => participatory_process.short_description[locale] },
      "slug" => participatory_process.slug,
      "startDate" => participatory_process.start_date.to_s,
      "steps" => [
        {
          "active" => participatory_process.steps.first.active,
          "callToActionPath" => participatory_process.steps.first.cta_path,
          "callToActionText" => { "translation" => participatory_process.steps.first.cta_text[locale] },
          "createdAt" => participatory_process.steps.first.created_at.to_time.iso8601,
          "description" => { "translation" => participatory_process.steps.first.description[locale] },
          "endDate" => participatory_process.steps.first.end_date&.to_time&.iso8601,
          "id" => participatory_process.steps.first.id.to_s,
          "participatoryProcess" => { "id" => participatory_process.id.to_s },
          "position" => participatory_process.steps.first.position,
          "startDate" => participatory_process.steps.first.start_date&.to_time&.iso8601,
          "title" => { "translation" => participatory_process.steps.first.title[locale] },
          "updatedAt" => participatory_process.steps.first.updated_at.to_time.iso8601
        }
      ],
      "subtitle" => { "translation" => participatory_process.subtitle[locale] },
      "target" => { "translation" => participatory_process.target[locale] },
      "title" => { "translation" => participatory_process.title[locale] },
      "type" => "Decidim::ParticipatoryProcess",
      "updatedAt" => participatory_process.updated_at.to_time.iso8601,
      "url" => Decidim::EngineRouter.main_proxy(participatory_process).participatory_process_url(participatory_process),
      "weight" => participatory_process.weight
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
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      data = response["participatoryProcess"]
      expect(data).to include(participatory_process_response)
      expect(data["heroImage"]).to be_blob_url(participatory_process.hero_image.blob)
    end

    it_behaves_like "implements stats type" do
      let(:participatory_process_query) do
        %(
          participatoryProcess{
            stats{
              name { translation(locale: "en") }
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
