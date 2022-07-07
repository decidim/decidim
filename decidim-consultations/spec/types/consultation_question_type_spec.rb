# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Consultations
    describe ConsultationQuestionType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:question) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "subtitle" do
        let(:query) { '{ subtitle { translation(locale: "en")}}' }

        it "returns the subtitle field" do
          expect(response["subtitle"]["translation"]).to eq(model.subtitle["en"])
        end
      end

      describe "slug" do
        let(:query) { "{ slug }" }

        it "returns the consultation' slug" do
          expect(response["slug"]).to eq(model.slug)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the consultation was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the consultation was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the consultation was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "bannerImage" do
        let(:query) { "{ bannerImage }" }

        it "returns the banner image field" do
          expect(response["bannerImage"]).to eq(model.attached_uploader(:banner_image).path)
        end
      end

      describe "heroImage" do
        let(:query) { "{ heroImage }" }

        it "returns the hero image field" do
          expect(response["heroImage"]).to eq(model.attached_uploader(:hero_image).path)
        end
      end

      describe "whatIsDecided" do
        let(:query) { '{ whatIsDecided { translation(locale: "en")}}' }

        it "returns the whatIsDecided field" do
          expect(response["whatIsDecided"]["translation"]).to eq(model.what_is_decided["en"])
        end
      end

      describe "promoterGroup" do
        let(:query) { '{ promoterGroup { translation(locale: "en")}}' }

        it "returns the promoterGroup field" do
          expect(response["promoterGroup"]["translation"]).to eq(model.promoter_group["en"])
        end
      end

      describe "participatoryScope" do
        let(:query) { '{ participatoryScope { translation(locale: "en")}}' }

        it "returns the participatoryScope field" do
          expect(response["participatoryScope"]["translation"]).to eq(model.participatory_scope["en"])
        end
      end

      describe "questionContext" do
        let(:query) { '{ questionContext { translation(locale: "en")}}' }

        it "returns the questionContext field" do
          expect(response["questionContext"]["translation"]).to eq(model.question_context["en"])
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the reference field" do
          expect(response["reference"]).to eq(model.reference)
        end
      end

      describe "hashtag" do
        let(:query) { "{ hashtag }" }

        it "returns the hashtag field" do
          expect(response["hashtag"]).to eq(model.hashtag)
        end
      end

      describe "votesCount" do
        let(:query) { "{ votesCount }" }

        it "returns the votesCount field" do
          expect(response["votesCount"]).to eq(model.votes_count)
        end
      end

      describe "originScope" do
        let(:query) { '{ originScope { translation(locale: "en")}}' }

        it "returns the originScope field" do
          expect(response["originScope"]).to be_nil
        end
      end

      describe "originTitle" do
        let(:query) { '{ originTitle { translation(locale: "en")}}' }

        it "returns the originTitle field" do
          expect(response["originTitle"]).to be_nil
        end
      end

      describe "originUrl" do
        let(:query) { "{ originUrl }" }

        it "returns the origin Url field" do
          expect(response["originUrl"]).to eq(model.origin_url)
        end
      end

      describe "iFrameUrl" do
        let(:query) { "{ iFrameUrl }" }

        it "returns the iFrameUrl field" do
          expect(response["iFrameUrl"]).to eq(model.i_frame_url)
        end
      end

      describe "externalVoting" do
        let(:query) { "{ externalVoting }" }

        it "returns the externalVoting field" do
          expect(response["externalVoting"]).to eq(model.external_voting)
        end
      end

      describe "responsesCount" do
        let(:query) { "{ responsesCount }" }

        it "returns the responsesCount field" do
          expect(response["responsesCount"]).to eq(model.responses_count)
        end
      end

      describe "order" do
        let(:query) { "{ order }" }

        it "returns the order field" do
          expect(response["order"]).to eq(model.order)
        end
      end

      describe "maxVotes" do
        let(:query) { "{ maxVotes }" }

        it "returns the maxVotes field" do
          expect(response["maxVotes"]).to eq(model.max_votes)
        end
      end

      describe "minVotes" do
        let(:query) { "{ minVotes }" }

        it "returns the minVotes field" do
          expect(response["minVotes"]).to eq(model.min_votes)
        end
      end

      describe "responseGroupsCount" do
        let(:query) { "{ responseGroupsCount }" }

        it "returns the responseGroupsCount field" do
          expect(response["responseGroupsCount"]).to eq(model.response_groups_count)
        end
      end

      describe "instructions" do
        let(:query) { '{ instructions { translation(locale: "en")}}' }

        it "returns the instructions field" do
          expect(response["instructions"]).to be_nil
        end
      end
    end
  end
end
