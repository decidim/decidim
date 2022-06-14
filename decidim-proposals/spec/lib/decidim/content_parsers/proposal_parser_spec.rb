# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ContentParsers
    describe ProposalParser do
      let(:organization) { create(:organization) }
      let(:component) { create(:proposal_component, organization: organization) }
      let(:context) { { current_organization: organization } }
      let!(:parser) { Decidim::ContentParsers::ProposalParser.new(content, context) }

      describe "ContentParser#parse is invoked" do
        let(:content) { "" }

        it "must call ProposalParser.parse" do
          expect(described_class).to receive(:new).with(content, context).and_return(parser)

          result = Decidim::ContentProcessor.parse(content, context)

          expect(result.rewrite).to eq ""
          expect(result.metadata[:proposal].class).to eq Decidim::ContentParsers::ProposalParser::Metadata
        end
      end

      describe "on parse" do
        subject { parser.rewrite }

        context "when content is nil" do
          let(:content) { nil }

          it { is_expected.to eq("") }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to eq([])
          end
        end

        context "when content is empty string" do
          let(:content) { "" }

          it { is_expected.to eq("") }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to eq([])
          end
        end

        context "when conent has no links" do
          let(:content) { "whatever content with @mentions and #hashes but no links." }

          it { is_expected.to eq(content) }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to eq([])
          end
        end

        context "when content links to an organization different from current" do
          let(:proposal) { create(:proposal, component: component) }
          let(:external_proposal) { create(:proposal, component: create(:proposal_component, organization: create(:organization))) }
          let(:content) do
            url = proposal_url(external_proposal)
            "This content references proposal #{url}."
          end

          it { is_expected.to eq(content) }

          it "does not recognize the proposal" do
            subject
            expect(parser.metadata.linked_proposals).to eq([])
          end
        end

        context "when content has one link" do
          let(:proposal) { create(:proposal, component: component) }
          let(:content) do
            url = proposal_url(proposal)
            "This content references proposal #{url}."
          end

          it { is_expected.to eq("This content references proposal #{proposal.to_global_id}.") }

          it "has metadata with the proposal" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to eq([proposal.id])
          end
        end

        context "when content has one link that is a simple domain" do
          let(:link) { "aaa:bbb" }
          let(:content) do
            "This content contains #{link} which is not a URI."
          end

          it { is_expected.to eq(content) }

          it "has metadata with the proposal" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to be_empty
          end
        end

        context "when content has many links" do
          let(:proposal1) { create(:proposal, component: component) }
          let(:proposal2) { create(:proposal, component: component) }
          let(:proposal3) { create(:proposal, component: component) }
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
            expect(parser.metadata.linked_proposals).to eq([proposal1.id, proposal2.id, proposal3.id])
          end
        end

        context "when content has a link that is not in a proposals component" do
          let(:proposal) { create(:proposal, component: component) }
          let(:content) do
            url = proposal_url(proposal).sub(%r{/proposals/}, "/something-else/")
            "This content references a non-proposal with same ID as a proposal #{url}."
          end

          it { is_expected.to eq(content) }

          it "has metadata with no reference to the proposal" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to be_empty
          end
        end

        context "when content has words similar to links but not links" do
          let(:similars) do
            %w(AA:aaa AA:sss aa:aaa aa:sss aaa:sss aaaa:sss aa:ssss aaa:ssss)
          end
          let(:content) do
            "This content has similars to links: #{similars.join}. Great! Now are not treated as links"
          end

          it { is_expected.to eq(content) }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to be_empty
          end
        end

        context "when proposal in content does not exist" do
          let(:proposal) { create(:proposal, component: component) }
          let(:url) { proposal_url(proposal) }
          let(:content) do
            proposal.destroy
            "This content references proposal #{url}."
          end

          it { is_expected.to eq("This content references proposal #{url}.") }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to eq([])
          end
        end

        context "when proposal is linked via ID" do
          let(:proposal) { create(:proposal, component: component) }
          let(:content) { "This content references proposal ~#{proposal.id}." }

          it { is_expected.to eq("This content references proposal #{proposal.to_global_id}.") }

          it "has metadata with the proposal" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::ProposalParser::Metadata)
            expect(parser.metadata.linked_proposals).to eq([proposal.id])
          end
        end
      end

      def proposal_url(proposal)
        Decidim::ResourceLocatorPresenter.new(proposal).url
      end
    end
  end
end
