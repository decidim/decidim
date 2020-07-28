# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ContentRenderers
    describe ProposalRenderer do
      let!(:renderer) { Decidim::ContentRenderers::ProposalRenderer.new(content) }

      describe "on parse" do
        subject { renderer.render }

        context "when content is nil" do
          let(:content) { nil }

          it { is_expected.to eq("") }
        end

        context "when content is empty string" do
          let(:content) { "" }

          it { is_expected.to eq("") }
        end

        context "when conent has no gids" do
          let(:content) { "whatever content with @mentions and #hashes but no gids." }

          it { is_expected.to eq(content) }
        end

        context "when content has one gid" do
          let(:proposal) { create(:proposal) }
          let(:content) do
            "This content references proposal #{proposal.to_global_id}."
          end

          it { is_expected.to eq("This content references proposal #{proposal_as_html_link(proposal)}.") }
        end

        context "when content has many links" do
          let(:proposal_1) { create(:proposal) }
          let(:proposal_2) { create(:proposal) }
          let(:proposal_3) { create(:proposal) }
          let(:content) do
            gid1 = proposal_1.to_global_id
            gid2 = proposal_2.to_global_id
            gid3 = proposal_3.to_global_id
            "This content references the following proposals: #{gid1}, #{gid2} and #{gid3}. Great?I like them!"
          end

          it { is_expected.to eq("This content references the following proposals: #{proposal_as_html_link(proposal_1)}, #{proposal_as_html_link(proposal_2)} and #{proposal_as_html_link(proposal_3)}. Great?I like them!") }
        end
      end

      def proposal_url(proposal)
        Decidim::ResourceLocatorPresenter.new(proposal).path
      end

      def proposal_as_html_link(proposal)
        href = proposal_url(proposal)
        title = translated(proposal.title)
        %(<a href="#{href}">#{title}</a>)
      end
    end
  end
end
