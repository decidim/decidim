# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe UserModerationType do
      include_context "with a graphql class type"

      let(:current_organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :blocked, organization: current_organization) }
      let(:reporter) { create(:user, :confirmed, organization: current_organization) }
      let(:moderation) { create(:user_moderation, user:) }
      let!(:user_block) { create(:user_block, user:, blocking_user: reporter) }
      let!(:user_report) { create(:user_report, user: reporter, reason: "spam", details: "Lorem ipsum", moderation:) }

      let(:model) { moderation }

      include_examples "timestamps interface"

      describe "about" do
        let(:query) { "{ about }" }

        it "returns the about field" do
          expect(response).to eq("about" => user.about)
        end
      end

      describe "block_reasons" do
        let(:query) { "{ blockReasons }" }

        it "returns the block_reasons field" do
          expect(response).to eq("blockReasons" => user_block.justification)
        end
      end

      describe "blocked_at" do
        let(:query) { "{ blockedAt }" }

        it "returns the blocked at date field" do
          expect(response).to eq("blockedAt" => user.blocked_at.to_time.iso8601)
        end
      end

      describe "blocking_user" do
        let(:query) { "{ blockingUser { id } }" }

        it "returns the blocking user object" do
          expect(response).to eq("blockingUser" => { "id" => user_block.blocking_user.id.to_s })
        end
      end

      describe "reports" do
        let(:query) { "{ reports { id } }" }

        it "returns the reports field" do
          expect(response["reports"]).to include({ "id" => user_report.id.to_s })
        end
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to eq("id" => moderation.id.to_s)
        end
      end

      describe "user_id" do
        let(:query) { "{ userId }" }

        it "returns the blocked user id field" do
          expect(response).to eq("userId" => moderation.user.id.to_s)
        end
      end
    end
  end
end
