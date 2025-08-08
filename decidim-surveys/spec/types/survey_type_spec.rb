# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Surveys
    describe SurveyType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:survey) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "allow_editing_responses" do
        let(:query) { "{ allowEditingResponses }" }

        context "when is set" do
          let(:model) { create(:survey, :allow_edit) }

          it "returns the allowEditingResponses field" do
            expect(response["allowEditingResponses"]).to eq(model.allow_editing_responses)
            expect(response["allowEditingResponses"]).to be_truthy
          end
        end

        context "when is not set" do
          it "returns the allowEditingResponses field" do
            expect(response["allowEditingResponses"]).to eq(model.allow_editing_responses)
          end
        end
      end

      describe "allow_responses" do
        let(:query) { "{ allowResponses }" }

        context "when is set" do
          let(:model) { create(:survey, :allow_responses) }

          it "returns the allowResponses field" do
            expect(response["allowResponses"]).to eq(model.allow_responses)
            expect(response["allowResponses"]).to be_truthy
          end
        end

        context "when is not set" do
          it "returns the allowResponses field" do
            expect(response["allowResponses"]).to eq(model.allow_responses)
          end
        end
      end

      describe "allow_unregistered" do
        let(:query) { "{ allowUnregistered }" }

        context "when is set" do
          let(:model) { create(:survey, :allow_unregistered) }

          it "returns the allowUnregistered field" do
            expect(response["allowUnregistered"]).to eq(model.allow_unregistered)
            expect(response["allowUnregistered"]).to be_truthy
          end
        end

        context "when is not set" do
          it "returns the allowUnregistered field" do
            expect(response["allowUnregistered"]).to eq(model.allow_unregistered)
          end
        end
      end

      describe "ends_at" do
        let(:query) { "{ endsAt }" }

        context "when is set" do
          let(:model) { create(:survey, ends_at: Time.current.utc) }

          it "returns the endsAt field" do
            expect(response["endsAt"]).to eq(model.ends_at.to_time.iso8601)
          end
        end

        context "when is not set" do
          it "returns the endsAt field" do
            expect(response["endsAt"]).to eq(model.ends_at)
            expect(response["endsAt"]).to be_nil
          end
        end
      end

      describe "published_at" do
        let(:query) { "{ publishedAt }" }

        context "when is set" do
          let(:model) { create(:survey, published_at: Time.current.utc) }

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

      describe "starts_at" do
        let(:query) { "{ startsAt }" }

        context "when is set" do
          let(:model) { create(:survey, starts_at: Time.current.utc) }

          it "returns the startsAt field" do
            expect(response["startsAt"]).to eq(model.starts_at.to_time.iso8601)
          end
        end

        context "when is not set" do
          it "returns the startsAt field" do
            expect(response["startsAt"]).to eq(model.starts_at)
            expect(response["startsAt"]).to be_nil
          end
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the survey was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "announcement" do
        let(:query) { '{ announcement { translation(locale: "en") } }' }

        it "returns when the survey was created" do
          expect(response["announcement"]).to eq(translated(model.announcement))
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the survey was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(Decidim::ResourceLocatorPresenter.new(model).url)
        end
      end

      describe "questionnaire" do
        let(:query) { "{ questionnaire { id }} " }

        it "returns the questionnaire" do
          expect(response["questionnaire"]["id"]).to eq(model.questionnaire.id.to_s)
        end
      end
    end
  end
end
