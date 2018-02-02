# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ContentParsers
    describe ProposalParser do
      let!(:parser) { Decidim::ContentParsers::ProposalParser.new(content) }

      describe "on parse" do
        subject { parser.rewrite }

        context "when content is nil" do
          let(:content) { nil }

          it { is_expected.to eq("") }
        end

        context "when content is empty string" do
          let(:content) { "" }

          it { is_expected.to eq("") }
        end

        context "when conent has no links" do
          let(:content) { "whatever content with @mentions and #hashes but no links." }

          it { is_expected.to eq(content) }
        end

        context "when content has one link" do
          let(:proposal) { create(:proposal) }
          let(:content) do
            url = proposal_url(proposal)
            "This content references proposal #{url}."
          end

          it { is_expected.to eq("This content references proposal #{proposal.to_global_id}.") }
        end

        context "when content has many links" do
          let(:proposal_1) { create(:proposal) }
          let(:proposal_2) { create(:proposal) }
          let(:proposal_3) { create(:proposal) }
          let(:content) do
            url_1 = proposal_url(proposal_1)
            url_2 = proposal_url(proposal_2)
            url_3 = proposal_url(proposal_3)
            "This content references the following proposals: #{url_1}, #{url_2} and #{url_3}. Great?I like them!"
          end

          it { is_expected.to eq("This content references the following proposals: #{proposal_1.to_global_id}, #{proposal_2.to_global_id} and #{proposal_3.to_global_id}. Great?I like them!") }
        end

        context "when proposal in content does not exist" do
          let(:proposal) { create(:proposal) }
          let(:url) { proposal_url(proposal) }
          let(:content) do
            proposal.destroy
            "This content references proposal #{url}."
          end

          it { is_expected.to eq("This content references proposal #{url}.") }
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
