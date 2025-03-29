# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let!(:taxonomy) { create(:taxonomy, :with_parent, organization: current_organization) }
  let!(:assembly) { create(:assembly, organization: current_organization, assembly_type:, taxonomies: [taxonomy]) }
  let(:assembly_type) { create(:assemblies_type, organization: current_organization) }
  let!(:follows) { create_list(:follow, 3, followable: assembly) }
  let(:assembly_data) do
    {
      "attachments" => [],
      "attachmentCollections" => [],
      "categories" => [],
      "children" => [],
      "childrenCount" => 0,
      "closingDate" => assembly.closing_date.to_date.to_s,
      "closingDateReason" => { "translation" => assembly.closing_date_reason[locale] },
      "components" => [],
      "composition" => { "translation" => assembly.composition[locale] },
      "createdAt" => assembly.created_at.to_time.iso8601,
      "createdBy" => assembly.created_by,
      "createdByOther" => { "translation" => assembly.created_by_other[locale] },
      "creationDate" => assembly.creation_date.to_date.to_s,
      "description" => { "translation" => assembly.description[locale] },
      "developerGroup" => { "translation" => assembly.developer_group[locale] },
      "duration" => assembly.duration.to_s,
      "facebookHandler" => assembly.facebook_handler,
      "followsCount" => 3,
      "githubHandler" => assembly.github_handler,
      "hashtag" => assembly.hashtag,
      "id" => assembly.id.to_s,
      "includedAt" => assembly.included_at.to_date.to_s,
      "instagramHandler" => assembly.instagram_handler,
      "internalOrganisation" => { "translation" => assembly.internal_organisation[locale] },
      "isTransparent" => assembly.is_transparent?,
      "linkedParticipatorySpaces" => [],
      "localArea" => { "translation" => assembly.local_area[locale] },
      "metaScope" => { "translation" => assembly.meta_scope[locale] },
      "parent" => assembly.parent,
      "parentsPath" => assembly.parents_path.to_s,
      "participatoryScope" => { "translation" => assembly.participatory_scope[locale] },
      "participatoryStructure" => { "translation" => assembly.participatory_structure[locale] },
      "privateSpace" => assembly.private_space?,
      "promoted" => assembly.promoted?,
      "publishedAt" => assembly.published_at.to_time.iso8601,
      "purposeOfAction" => { "translation" => assembly.purpose_of_action[locale] },
      "reference" => assembly.reference,
      "taxonomies" => [{ "id" => taxonomy.id.to_s, "name" => { "translation" => taxonomy.name[locale] }, "parent" => { "id" => taxonomy.parent_id.to_s }, "children" => taxonomy.children.map { |child| { "id" => child.id.to_s } } }],
      "shortDescription" => { "translation" => assembly.short_description[locale] },
      "slug" => assembly.slug,
      "specialFeatures" => { "translation" => assembly.special_features[locale] },
      "subtitle" => { "translation" => assembly.subtitle[locale] },
      "target" => { "translation" => assembly.target[locale] },
      "title" => { "translation" => assembly.title[locale] },
      "twitterHandler" => assembly.twitter_handler,
      "type" => assembly.class.name,
      "updatedAt" => assembly.updated_at.to_time.iso8601,
      "url" => Decidim::EngineRouter.main_proxy(assembly).assembly_url(assembly),
      "youtubeHandler" => assembly.youtube_handler,
      "weight" => assembly.weight
    }
  end
  let(:assemblies) do
    %(
      assemblies{
        attachments {
          thumbnail
        }
        attachmentCollections {
          name {
            translation(locale:"#{locale}")
          }
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
        followsCount
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
          translation(locale:"#{locale}")
        }
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
        url
        weight
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
      data = response["assemblies"].first
      expect(data).to include(assembly_data)
      expect(data["bannerImage"]).to be_blob_url(assembly.banner_image.blob)
      expect(data["heroImage"]).to be_blob_url(assembly.hero_image.blob)
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
        attachments {
          thumbnail
        }
        attachmentCollections {
          name {
            translation(locale:"#{locale}")
          }
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
        followsCount
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
          translation(locale:"#{locale}")
        }
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
        url
        weight
        youtubeHandler
      }
    )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      data = response["assembly"]
      expect(data).to include(assembly_data)
      expect(data["bannerImage"]).to be_blob_url(assembly.banner_image.blob)
      expect(data["heroImage"]).to be_blob_url(assembly.hero_image.blob)
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
