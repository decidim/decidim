# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Elections
    describe ElectionType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:election, :published, :complete) }

      it_behaves_like "attachable interface"

      it_behaves_like "traceable interface" do
        let(:author) { create(:user, :admin, organization: model.component.organization) }
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "startTime" do
        let(:query) { "{ startTime }" }

        it "returns the election's start time" do
          expect(Time.zone.parse(response["startTime"])).to be_within(1.second).of(model.start_time)
        end
      end

      describe "endTime" do
        let(:query) { "{ endTime }" }

        it "returns the election's end time" do
          expect(Time.zone.parse(response["endTime"])).to be_within(1.second).of(model.end_time)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns the election's published time" do
          expect(Time.zone.parse(response["publishedAt"])).to be_within(1.second).of(model.published_at)
        end
      end

      describe "blocked" do
        let(:query) { "{ blocked }" }

        context "when the election's parameters are blocked" do
          let!(:model) { create(:election, :created) }

          it "returns true" do
            expect(response["blocked"]).to be true
          end
        end

        context "when the election's parameters are not blocked" do
          let(:model) { create(:election) }

          it "returns false" do
            expect(response["blocked"]).to be_falsey
          end
        end
      end

      describe "bb_status" do
        let(:query) { "{ bb_status }" }

        it "returns the bb_status" do
          expect(response["bb_status"]).to eq(model.bb_status)
        end
      end

      describe "questions" do
        let!(:election2) { create(:election, :complete) }
        let(:query) { "{ questions { id } }" }

        it "returns the election questions" do
          ids = response["questions"].map { |question| question["id"] }
          expect(ids).to include(*model.questions.map(&:id).map(&:to_s))
          expect(ids).not_to include(*election2.questions.map(&:id).map(&:to_s))
        end
      end

      describe "trustees" do
        let(:query) { "{ trustees { id } }" }

        it "returns the election trustees" do
          ids = response["trustees"].map { |trustee| trustee["id"] }
          expect(ids).to include(*model.trustees.map(&:id).map(&:to_s))
        end
      end
    end
  end
end
