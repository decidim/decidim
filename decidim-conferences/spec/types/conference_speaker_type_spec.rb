# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Conferences
    describe ConferenceSpeakerType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:conference_speaker, :published) }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "fullName" do
        let(:query) { "{ fullName }" }

        it "returns the conference' fullName" do
          expect(response["fullName"]).to eq(model.full_name)
        end
      end

      describe "position" do
        let(:query) { '{ position { translation(locale: "en" )}}' }

        it "returns the position field" do
          expect(response["position"]["translation"]).to eq(model.position["en"])
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the conference was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "affiliation" do
        let(:query) { '{ affiliation { translation(locale: "en" )}}' }

        it "returns the affiliation field" do
          expect(response["affiliation"]["translation"]).to eq(model.affiliation["en"])
        end
      end

      describe "twitterHandle" do
        let(:query) { "{ twitterHandle }" }

        it "returns the conference speaker twitterHandle field" do
          expect(response["twitterHandle"]).to eq(model.twitter_handle)
        end
      end

      describe "shortBio" do
        let(:query) { '{ shortBio { translation(locale: "en" )}}' }

        it "returns the shortBio field" do
          expect(response["shortBio"]["translation"]).to eq(model.short_bio["en"])
        end
      end

      describe "personalUrl" do
        let(:query) { "{ personalUrl }" }

        it "returns the conference speaker personalUrl field" do
          expect(response["personalUrl"]).to eq(model.personal_url)
        end
      end

      describe "avatar" do
        let(:query) { "{ avatar }" }

        it "returns the conference speaker avatar field" do
          expect(response["avatar"]).to eq(model.attached_uploader(:avatar).url)
        end
      end

      describe "user" do
        let(:query) { "{ user { name } }" }

        it "returns the decidim user for this speaker" do
          expect(response["user"]).to be_nil
        end
      end

      context "when there is a user" do
        let(:conference) { create(:conference) }
        let(:user) { create(:user, :confirmed, organization: conference.organization) }
        let(:model) { create(:conference_speaker, :published, user:, conference:) }

        describe "user" do
          let(:query) { "{ user { name } }" }

          it "returns the decidim user for this speaker" do
            expect(response["user"]["name"]).to eq(model.user.name)
          end
        end
      end
    end
  end
end
