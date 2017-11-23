# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSerializer do
      subject do
        described_class.new(proposal)
      end

      let!(:proposal) { create(:proposal) }
      let!(:category) { create(:category, participatory_space: feature.participatory_space) }
      let!(:scope) { create(:scope, organization: feature.participatory_space.organization) }
      let(:participatory_process) { feature.participatory_space }
      let(:feature) { proposal.feature }

      let!(:meetings_feature) { create(:feature, manifest_name: "meetings", participatory_space: participatory_process) }
      let(:meetings) { create_list(:meeting, 2, feature: meetings_feature) }

      before do
        proposal.update_attributes!(category: category)
        proposal.update_attributes!(scope: scope)
        proposal.link_resources(meetings, "proposals_from_meeting")
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: proposal.id)
        end

        it "serializes the category" do
          expect(serialized[:category]).to include(id: category.id)
          expect(serialized[:category]).to include(name: category.name)
        end

        it "serializes the scope" do
          expect(serialized[:scope]).to include(id: scope.id)
          expect(serialized[:scope]).to include(name: scope.name)
        end

        it "serializes the title" do
          expect(serialized).to include(title: proposal.title)
        end

        it "serializes the body" do
          expect(serialized).to include(body: proposal.body)
        end

        it "serializes the amount of votes" do
          expect(serialized).to include(votes: proposal.proposal_votes_count)
        end

        it "serializes the amount of comments" do
          expect(serialized).to include(comments: proposal.comments.count)
        end

        it "serializes the date of creation" do
          expect(serialized).to include(created_at: proposal.created_at)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", proposal.id.to_s)
        end

        it "serializes the feature" do
          expect(serialized[:feature]).to include(id: proposal.feature.id)
        end

        it "serializes the meetings" do
          expect(serialized[:meeting_urls].length).to eq(2)
          expect(serialized[:meeting_urls].first).to match(%r{http.*/meetings})
        end
      end
    end
  end
end
