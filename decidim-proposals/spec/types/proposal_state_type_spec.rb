# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Proposals
    describe ProposalStateType, type: :graphql do
      include_context "with a graphql class type"
      let!(:component) { create(:proposal_component) }
      let(:model) { Decidim::Proposals::ProposalState.last }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the proposal's state id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "announcement_title" do
        let(:query) { '{ announcementTitle { translation(locale: "en")}}' }

        it "returns the proposal's state announcementTitle" do
          expect(response["announcementTitle"]["translation"]).to eq(translated(model.announcement_title))
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the proposal's state title" do
          expect(response["title"]["translation"]).to eq(translated(model.title))
        end
      end

      describe "bg_color" do
        let(:query) { "{ bgColor }" }

        it "returns the proposal's state bgColor" do
          expect(response["bgColor"]).to eq(model.bg_color)
        end
      end

      describe "text_color" do
        let(:query) { "{ textColor }" }

        it "returns the proposal's state textColor" do
          expect(response["textColor"]).to eq(model.text_color)
        end
      end

      describe "proposals_count" do
        let(:query) { "{ proposalsCount }" }

        it "returns the proposal's state proposalsCount" do
          expect(response["proposalsCount"]).to eq(model.proposals_count)
        end
      end
    end
  end
end
