# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe ModerationType do
      include_context "with a graphql class type"

      let(:model) { create(:moderation, :hidden, report_count: 1, reported_content: "This is the content") }
      let!(:report) { create(:report, moderation: model) }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

      describe "hiddenAt" do
        let(:query) { "{ hiddenAt }" }

        it "returns the hidden at date field" do
          expect(response).to eq("hiddenAt" => model.hidden_at.to_time.iso8601)
        end
      end

      describe "reportCount" do
        let(:query) { "{ reportCount }" }

        it "returns the report count field" do
          expect(response).to eq("reportCount" => 1)
        end
      end

      describe "reportedContent" do
        let(:query) { "{ reportedContent }" }

        it "returns the reported content" do
          expect(response).to eq("reportedContent" => translated(model.reported_content))
        end
      end

      describe "reportedUrl" do
        let(:query) { "{ reportedUrl }" }

        it "returns the reported content url field" do
          expect(response).to eq("reportedUrl" => model.reportable.reported_content_url)
        end
      end

      describe "reports" do
        let(:query) { "{ reports { id } }" }

        it "returns the reports" do
          expect(response["reports"].count).to eq(1)
          expect(response["reports"].first["id"]).to eq(report.id.to_s)
        end
      end
    end
  end
end
