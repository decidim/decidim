# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let!(:assembly) { create(:assembly, :with_type, organization: current_organization) }

  let(:assembly_data) do
    {
      "area" => nil,
      "assemblyType" => {
        "assemblies" => assembly.assembly_type.assemblies.map { |a| { "id" => a.id.to_s } },
        "createdAt" => assembly.assembly_type.created_at.iso8601.to_s.gsub("Z", "+00:00"),
        "id" => assembly.assembly_type.id.to_s,
        "title" => { "translation" => assembly.assembly_type.title[locale] },
        "updatedAt" => assembly.assembly_type.updated_at.iso8601.to_s.gsub("Z", "+00:00")
      },
      "attachments" => [],
      "bannerImage" => assembly.attached_uploader(:banner_image).path,
      "categories" => [],
      "children" => [],
      "childrenCount" => 0,
      "closingDate" => assembly.closing_date.to_date.to_s,
      "closingDateReason" => { "translation" => assembly.closing_date_reason[locale] },
      "components" => [],
      "composition" => { "translation" => assembly.composition[locale] },
      "createdAt" => assembly.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "createdBy" => assembly.created_by,
      "createdByOther" => { "translation" => assembly.created_by_other[locale] },
      "creationDate" => assembly.creation_date.to_date.to_s,
      "description" => { "translation" => assembly.description[locale] },
      "developerGroup" => { "translation" => assembly.developer_group[locale] },
      "duration" => assembly.duration.to_s,
      "facebookHandler" => assembly.facebook_handler,
      "githubHandler" => assembly.github_handler,
      "hashtag" => assembly.hashtag,
      "heroImage" => assembly.attached_uploader(:hero_image).path,
      "id" => assembly.id.to_s,
      "includedAt" => assembly.included_at.to_date.to_s,
      "instagramHandler" => assembly.instagram_handler,
      "internalOrganisation" => { "translation" => assembly.internal_organisation[locale] },
      "isTransparent" => assembly.is_transparent?,
      "linkedParticipatorySpaces" => [],
      "localArea" => { "translation" => assembly.local_area[locale] },
      "members" => assembly.members.map { |m| { "id" => m.id.to_s } },
      "metaScope" => { "translation" => assembly.meta_scope[locale] },
      "parent" => assembly.parent,
      "parentsPath" => assembly.parents_path.to_s,
      "participatoryScope" => { "translation" => assembly.participatory_scope[locale] },
      "participatoryStructure" => { "translation" => assembly.participatory_structure[locale] },
      "privateSpace" => assembly.private_space?,
      "promoted" => assembly.promoted?,
      "publishedAt" => assembly.published_at.iso8601.to_s.gsub("Z", "+00:00"),
      "purposeOfAction" => { "translation" => assembly.purpose_of_action[locale] },
      "reference" => assembly.reference,
      "scopesEnabled" => assembly.scopes_enabled?,
      "shortDescription" => { "translation" => assembly.short_description[locale] },
      "showStatistics" => assembly.show_statistics?,
      "slug" => assembly.slug,
      "specialFeatures" => { "translation" => assembly.special_features[locale] },
      "subtitle" => { "translation" => assembly.subtitle[locale] },
      "target" => { "translation" => assembly.target[locale] },
      "title" => { "translation" => assembly.title[locale] },
      "twitterHandler" => assembly.twitter_handler,
      "type" => assembly.class.name,
      "updatedAt" => assembly.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "youtubeHandler" => assembly.youtube_handler

    }
  end
  let(:assemblies) do
    %(
      assemblies{
        area {
          id
          areaType {
            id
            name{
              translation(locale:"#{locale}")
            }
            plural{
              translation(locale:"#{locale}")
            }
          }
          name{
            translation(locale:"#{locale}")
          }
          updatedAt
        }
        assemblyType {
          id
          assemblies {
            id
          }
          createdAt
          title{
            translation(locale:"#{locale}")
          }
          updatedAt
        }
        attachments {
          thumbnail
        }
        bannerImage
        categories {
          id
        }
        children {
          id
        }
        childrenCount
        closingDate
        closingDateReason {
          translation(locale:"#{locale}")
        }
        components {
          id
        }
        composition {
          translation(locale:"#{locale}")
        }
        createdAt
        createdBy
        createdByOther {
          translation(locale:"#{locale}")
        }
        creationDate
        description {
          translation(locale:"#{locale}")
        }
        developerGroup {
          translation(locale:"#{locale}")
        }
        duration
        facebookHandler
        githubHandler
        hashtag
        heroImage
        id
        includedAt
        instagramHandler
        internalOrganisation {
          translation(locale:"#{locale}")
        }
        isTransparent
        linkedParticipatorySpaces {
          id
        }
        localArea {
          translation(locale:"#{locale}")
        }
        members {
          id
        }
        metaScope {
          translation(locale:"#{locale}")
        }
        parent {
          id
        }
        parentsPath
        participatoryScope {
          translation(locale:"#{locale}")
        }
        participatoryStructure {
          translation(locale:"#{locale}")
        }
        privateSpace
        promoted
        publishedAt
        purposeOfAction {
          translation(locale:"#{locale}")
        }
        reference
        scopesEnabled
        shortDescription {
          translation(locale:"#{locale}")
        }
        showStatistics
        slug
        specialFeatures {
          translation(locale:"#{locale}")
        }
        subtitle {
          translation(locale:"#{locale}")
        }
        target {
          translation(locale:"#{locale}")
        }
        title {
          translation(locale:"#{locale}")
        }
        twitterHandler
        type
        updatedAt
        youtubeHandler
      }
    )
  end

  let(:query) do
    %(
      query {
        #{assemblies}
      }
    )
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["assemblies"].first).to eq(assembly_data)
    end

    it_behaves_like "implements stats type" do
      let(:assemblies) do
        %(
          assemblies{
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["assemblies"].first["stats"] }
    end
  end

  describe "single assembly" do
    let(:assemblies) do
      %(
      assembly(id: #{assembly.id}){
        area {
          id
          areaType {
            id
            name{
              translation(locale:"#{locale}")
            }
            plural{
              translation(locale:"#{locale}")
            }
          }
          name{
            translation(locale:"#{locale}")
          }
          updatedAt
        }
        assemblyType {
          id
          assemblies {
            id
          }
          createdAt
          title{
            translation(locale:"#{locale}")
          }
          updatedAt
        }
        attachments {
          thumbnail
        }
        bannerImage
        categories {
          id
        }
        children {
          id
        }
        childrenCount
        closingDate
        closingDateReason {
          translation(locale:"#{locale}")
        }
        components {
          id
        }
        composition {
          translation(locale:"#{locale}")
        }
        createdAt
        createdBy
        createdByOther {
          translation(locale:"#{locale}")
        }
        creationDate
        description {
          translation(locale:"#{locale}")
        }
        developerGroup {
          translation(locale:"#{locale}")
        }
        duration
        facebookHandler
        githubHandler
        hashtag
        heroImage
        id
        includedAt
        instagramHandler
        internalOrganisation {
          translation(locale:"#{locale}")
        }
        isTransparent
        linkedParticipatorySpaces {
          id
        }
        localArea {
          translation(locale:"#{locale}")
        }
        members {
          id
        }
        metaScope {
          translation(locale:"#{locale}")
        }
        parent {
          id
        }
        parentsPath
        participatoryScope {
          translation(locale:"#{locale}")
        }
        participatoryStructure {
          translation(locale:"#{locale}")
        }
        privateSpace
        promoted
        publishedAt
        purposeOfAction {
          translation(locale:"#{locale}")
        }
        reference
        scopesEnabled
        shortDescription {
          translation(locale:"#{locale}")
        }
        showStatistics
        slug
        specialFeatures {
          translation(locale:"#{locale}")
        }
        subtitle {
          translation(locale:"#{locale}")
        }
        target {
          translation(locale:"#{locale}")
        }
        title {
          translation(locale:"#{locale}")
        }
        twitterHandler
        type
        updatedAt
        youtubeHandler
      }
    )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["assembly"]).to eq(assembly_data)
    end

    it_behaves_like "implements stats type" do
      let(:assemblies) do
        %(
          assembly(id: #{assembly.id}){
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["assembly"]["stats"] }
    end
  end
end
