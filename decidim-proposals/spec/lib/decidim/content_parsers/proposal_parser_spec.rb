# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ContentParsers
    describe ProposalParser do
      let(:organization) { create(:organization) }
      let(:feature) { create(:proposal_feature, organization: organization) }
      let(:context) { { current_organization: organization } }
      let!(:parser) { Decidim::ContentParsers::ProposalParser.new(content, context) }

      describe "on parse" do
        subject { parser.rewrite }

        context "when content is nil" do
          let(:content) { nil }

          it { is_expected.to eq("") }
          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.proposals).to eq([])
          end
        end

        context "when content is empty string" do
          let(:content) { "" }

          it { is_expected.to eq("") }
          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.proposals).to eq([])
          end
        end

        context "when conent has no links" do
          let(:content) { "whatever content with @mentions and #hashes but no links." }

          it { is_expected.to eq(content) }
          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.proposals).to eq([])
          end
        end

        context "when content links to an organization different from current" do
          let(:proposal) { create(:proposal, feature: feature) }
          let(:external_proposal) { create(:proposal, feature: create(:proposal_feature, organization: create(:organization))) }
          let(:content) do
            url = proposal_url(external_proposal)
            "This content references proposal #{url}."
          end

          it "does not recognize the proposal" do
            subject
            expect(parser.metadata.proposals).to eq([])
          end
        end

        context "when content has one link" do
          let(:proposal) { create(:proposal, feature: feature) }
          let(:content) do
            url = proposal_url(proposal)
            "This content references proposal #{url}."
          end

          it { is_expected.to eq("This content references proposal #{proposal.to_global_id}.") }
          it "has metadata with the proposal" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.proposals).to eq([proposal])
          end
        end

        context "when content has many links" do
          let(:proposal1) { create(:proposal, feature: feature) }
          let(:proposal2) { create(:proposal, feature: feature) }
          let(:proposal3) { create(:proposal, feature: feature) }
          let(:content) do
            url1 = proposal_url(proposal1)
            url2 = proposal_url(proposal2)
            url3 = proposal_url(proposal3)
            "This content references the following proposals: #{url1}, #{url2} and #{url3}. Great?I like them!"
          end

          it { is_expected.to eq("This content references the following proposals: #{proposal1.to_global_id}, #{proposal2.to_global_id} and #{proposal3.to_global_id}. Great?I like them!") }
          it "has metadata with all linked proposals" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.proposals).to eq([proposal1, proposal2, proposal3])
          end
        end

        context "when proposal in content does not exist" do
          let(:proposal) { create(:proposal, feature: feature) }
          let(:url) { proposal_url(proposal) }
          let(:content) do
            proposal.destroy
            "This content references proposal #{url}."
          end

          it { is_expected.to eq("This content references proposal #{url}.") }
          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.proposals).to eq([])
          end
        end

        context "when proposal is linked via ID" do
          let(:proposal) { create(:proposal, feature: feature) }
          let(:content) { "This content references proposal ~#{proposal.id}." }

          it { is_expected.to eq("This content references proposal #{proposal.to_global_id}.") }
          it "has metadata with the proposal" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.proposals).to eq([proposal])
          end
        end
      end

      def proposal_url(proposal)
        host = proposal.organization.host
        f = proposal.feature
        url = "http://#{host}/processes/#{f.participatory_space.slug}/f/#{f.id}/proposals/#{proposal.id}"
        url
      end
    end
  end
end
