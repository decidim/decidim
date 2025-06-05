# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Forms
    describe QuestionnaireType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:questionnaire) }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the questionnaire's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { "{ title { translation(locale: \"ca\") } }" }

        it "returns the questionnaire's title" do
          expect(response["title"]["translation"]).to eq(model.title["ca"])
        end
      end

      describe "published_at" do
        let(:query) { "{ publishedAt }" }

        context "when is set" do
          let(:model) { create(:questionnaire, published_at: Time.current.utc) }

          it "returns the publishedAt field" do
            expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
          end
        end

        context "when is not set" do
          it "returns the publishedAt field" do
            expect(response["publishedAt"]).to eq(model.published_at)
            expect(response["publishedAt"]).to be_nil
          end
        end
      end

      describe "description" do
        let(:query) { "{ description { translation(locale: \"ca\") } }" }

        it "returns the questionnaire's description" do
          expect(response["description"]["translation"]).to eq(model.description["ca"])
        end
      end

      describe "tos" do
        let(:query) { "{ tos { translation(locale: \"ca\") } }" }

        it "returns the questionnaire's tos" do
          expect(response["tos"]["translation"]).to eq(model.tos["ca"])
        end
      end

      describe "forType" do
        let(:query) { "{ forType }" }

        it "returns the questionnaire's questionnaire_for_type" do
          expect(response["forType"]).to eq(model.questionnaire_for_type)
        end
      end

      describe "forEntity" do
        let(:query) { "{ forEntity { id } }" }

        before do
          model.update(questionnaire_for: meeting)
        end

        context "when meeting is published" do
          let(:meeting) { create(:meeting, :published) }

          it "returns the questionnaire's entity corresponding to questionnaire_for_id" do
            expect(response["forEntity"]["id"]).to eq(model.questionnaire_for.id.to_s)
          end
        end

        context "when meeting is no published" do
          let(:meeting) { create(:meeting) }

          it "returns the questionnaire's entity corresponding to questionnaire_for_id" do
            expect(response["forEntity"]).to be_nil
          end
        end
      end
    end
  end
end
