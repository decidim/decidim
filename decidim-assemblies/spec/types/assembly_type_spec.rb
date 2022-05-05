# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/participatory_space_resourcable_interface_examples"

module Decidim
  module Assemblies
    describe AssemblyType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:assembly) }

      include_examples "attachable interface"
      include_examples "participatory space resourcable interface"
      include_examples "categories container interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "slug" do
        let(:query) { "{ slug }" }

        it "returns the Assembly' slug" do
          expect(response["slug"]).to eq(model.slug)
        end
      end

      describe "hashtag" do
        let(:query) { "{ hashtag }" }

        it "returns the Assembly' hashtag" do
          expect(response["hashtag"]).to eq(model.hashtag)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the Assembly was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the Assembly was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the Assembly was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the Assembly' reference" do
          expect(response["reference"]).to eq(model.reference)
        end
      end

      describe "heroImage" do
        let(:query) { "{ heroImage }" }

        it "returns the hero image field" do
          expect(response["heroImage"]).to eq(model.attached_uploader(:hero_image).path)
        end
      end

      describe "bannerImage" do
        let(:query) { "{ bannerImage }" }

        it "returns the banner image field" do
          expect(response["bannerImage"]).to eq(model.attached_uploader(:banner_image).path)
        end
      end

      describe "promoted" do
        let(:query) { "{ promoted }" }

        it "returns the promoted field" do
          expect(response["promoted"]).to eq(model.promoted)
        end
      end

      describe "developerGroup" do
        let(:query) { '{ developerGroup { translation(locale: "en")}}' }

        it "returns the developerGroup field" do
          expect(response["developerGroup"]["translation"]).to eq(model.developer_group["en"])
        end
      end

      describe "metaScope" do
        let(:query) { '{ metaScope { translation(locale: "en")}}' }

        it "returns the metaScope field" do
          expect(response["metaScope"]["translation"]).to eq(model.meta_scope["en"])
        end
      end

      describe "localArea" do
        let(:query) { '{ localArea { translation(locale: "en")}}' }

        it "returns the localArea field" do
          expect(response["localArea"]["translation"]).to eq(model.local_area["en"])
        end
      end

      describe "target" do
        let(:query) { '{ target { translation(locale: "en" )}}' }

        it "returns the target field" do
          expect(response["target"]["translation"]).to eq(model.target["en"])
        end
      end

      describe "participatoryScope" do
        let(:query) { '{ participatoryScope { translation(locale: "en" )}}' }

        it "returns the participatoryScope field" do
          expect(response["participatoryScope"]["translation"]).to eq(model.participatory_scope["en"])
        end
      end

      describe "participatoryStructure" do
        let(:query) { '{ participatoryStructure { translation(locale: "en" )} }' }

        it "returns the participatoryStructure field" do
          expect(response["participatoryStructure"]["translation"]).to eq(model.participatory_structure["en"])
        end
      end

      describe "showStatistics" do
        let(:query) { "{ showStatistics }" }

        it "returns the showStatistics field" do
          expect(response["showStatistics"]).to eq(model.show_statistics)
        end
      end

      describe "scopesEnabled" do
        let(:query) { "{ scopesEnabled }" }

        it "returns the scopesEnabled field" do
          expect(response["scopesEnabled"]).to eq(model.scopes_enabled)
        end
      end

      describe "privateSpace" do
        let(:query) { "{ privateSpace }" }

        it "returns the privateSpace field" do
          expect(response["privateSpace"]).to eq(model.private_space)
        end
      end

      describe "area" do
        let(:query) { "{ area { id } }" }

        it "returns the area field" do
          expect(response["area"]).to be_nil
        end
      end

      describe "parent" do
        let(:query) { "{ parent { id }}" }

        context "when has no parent" do
          it "returns the parent" do
            expect(response["parent"]).to be_nil
          end
        end

        context "when has parent" do
          let!(:parent) { create(:assembly, organization: model.organization, children: [model]) }

          it "returns the parent" do
            expect(response["parent"]["id"]).to eq(parent.id.to_s)
          end
        end
      end

      describe "parentsPath" do
        let(:query) { "{ parentsPath }" }

        it "returns the parentsPath field" do
          expect(response["parentsPath"]).to eq(model.parents_path)
        end
      end

      describe "childrenCount" do
        let!(:children) { create(:assembly, organization: model.organization, parent: model) }
        let(:query) { "{ childrenCount }" }

        it "returns the childrenCount field" do
          expect(response["childrenCount"]).to eq(model.children_count)
          expect(response["childrenCount"]).to eq(1)
        end
      end

      describe "children" do
        let!(:children) { create(:assembly, organization: model.organization, parent: model) }
        let(:query) { "{ children { id } }" }

        it "returns the children field" do
          expect(response["children"].first["id"]).to eq(children.id.to_s)
        end
      end

      describe "purposeOfAction" do
        let(:query) { '{ purposeOfAction { translation(locale: "en" )}}' }

        it "returns the purposeOfAction field" do
          expect(response["purposeOfAction"]["translation"]).to eq(model.purpose_of_action["en"])
        end
      end

      describe "composition" do
        let(:query) { '{ composition { translation(locale: "en" )}}' }

        it "returns the composition field" do
          expect(response["composition"]["translation"]).to eq(model.composition["en"])
        end
      end

      describe "assemblyType" do
        let(:query) { "{ assemblyType { id } }" }

        it "returns the assemblyType field" do
          expect(response["assemblyType"]).to be_nil
        end
      end

      context "when there is type" do
        let(:model) { create(:assembly, :with_type) }

        describe "assemblyeType" do
          let(:query) { "{ assemblyType { id } }" }

          it "returns the assemblyType field" do
            expect(response["assemblyType"]["id"]).to eq(model.assembly_type.id.to_s)
          end
        end
      end

      describe "creationDate" do
        let(:query) { "{ creationDate }" }

        it "returns the assembly creation date field" do
          expect(response["creationDate"]).to eq(model.creation_date.to_date.iso8601)
        end
      end

      describe "createdBy" do
        let(:query) { "{ createdBy }" }

        it "returns the createdBy field" do
          expect(response["createdBy"]).to eq(model.created_by)
        end
      end

      describe "createdByOther" do
        let(:query) { '{ createdByOther { translation(locale: "en" )} }' }

        it "returns the createdByOther field" do
          expect(response["createdByOther"]["translation"]).to eq(model.created_by_other["en"])
        end
      end

      describe "duration" do
        let(:query) { "{ duration }" }

        it "returns the assembly duration field" do
          expect(response["duration"]).to eq(model.duration.to_date.iso8601)
        end
      end

      describe "includedAt" do
        let(:query) { "{ includedAt }" }

        it "returns the assembly creation date field" do
          expect(response["includedAt"]).to eq(model.included_at.to_date.iso8601)
        end
      end

      describe "closingDate" do
        let(:query) { "{ closingDate }" }

        it "returns the assembly creation date field" do
          expect(response["closingDate"]).to eq(model.closing_date.to_date.iso8601)
        end
      end

      describe "closingDateReason" do
        let(:query) { '{ closingDateReason { translation(locale: "en" )} }' }

        it "returns the closingDateReason field" do
          expect(response["closingDateReason"]["translation"]).to eq(model.closing_date_reason["en"])
        end
      end

      describe "internalOrganisation" do
        let(:query) { '{ internalOrganisation { translation(locale: "en" )} }' }

        it "returns the internalOrganisation field" do
          expect(response["internalOrganisation"]["translation"]).to eq(model.internal_organisation["en"])
        end
      end

      describe "isTransparent" do
        let(:query) { "{ isTransparent }" }

        it "returns the assembly isTransparent field" do
          expect(response["isTransparent"]).to eq(model.is_transparent)
        end
      end

      describe "specialFeatures" do
        let(:query) { '{ specialFeatures { translation(locale: "en" ) }}' }

        it "returns the specialFeatures field" do
          expect(response["specialFeatures"]["translation"]).to eq(model.special_features["en"])
        end
      end

      describe "twitterHandler" do
        let(:query) { "{ twitterHandler }" }

        it "returns the assembly twitterHandler field" do
          expect(response["twitterHandler"]).to eq(model.twitter_handler)
        end
      end

      describe "instagramHandler" do
        let(:query) { "{ instagramHandler }" }

        it "returns the assembly instagramHandler field" do
          expect(response["instagramHandler"]).to eq(model.instagram_handler)
        end
      end

      describe "facebookHandler" do
        let(:query) { "{ facebookHandler }" }

        it "returns the assembly facebookHandler field" do
          expect(response["facebookHandler"]).to eq(model.facebook_handler)
        end
      end

      describe "youtubeHandler" do
        let(:query) { "{ youtubeHandler }" }

        it "returns the assembly youtubeHandler field" do
          expect(response["youtubeHandler"]).to eq(model.youtube_handler)
        end
      end

      describe "githubHandler" do
        let(:query) { "{ githubHandler }" }

        it "returns the assembly githubHandler field" do
          expect(response["githubHandler"]).to eq(model.github_handler)
        end
      end

      describe "announcement" do
        let(:query) { '{ announcement { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["announcement"]["translation"]).to eq(model.announcement["en"])
        end
      end
    end
  end
end
