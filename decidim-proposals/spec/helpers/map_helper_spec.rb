# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe MapHelper do
      include Decidim::LayoutHelper

      let!(:organization) { create(:organization) }
      let!(:proposal_component) { create(:proposal_component, :with_geocoding_enabled, organization:) }
      let!(:user) { create(:user, organization:) }
      let!(:proposals) { create_list(:proposal, 5, address:, latitude:, longitude:, component: proposal_component) }
      let!(:proposal) { proposals.first }
      let(:address) { "Carrer Pic de Peguera 15, 17003 Girona" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      describe "#has_position?" do
        subject { helper.has_position?(proposal) }

        it { is_expected.to be_truthy }

        context "when proposal is not geocoded" do
          let!(:proposals) { create_list(:proposal, 5, address:, latitude: nil, longitude: nil, component: proposal_component) }

          it { is_expected.to be_falsey }
        end
      end

      describe "#proposal_preview_data_for_map" do
        subject { helper.proposal_preview_data_for_map(proposal) }

        let(:marker) { subject[:marker] }

        it "returns preview data" do
          expect(subject[:type]).to eq("drag-marker")
          expect(marker["latitude"]).to eq(latitude)
          expect(marker["longitude"]).to eq(longitude)
          expect(marker["address"]).to eq(address)
          expect(marker["icon"]).to match(/<svg.+/)
        end
      end

      describe "#proposal_data_for_map" do
        subject { helper.proposal_data_for_map(proposal) }

        let(:fake_body) { "<script>alert(\"HEY\")</script> This is my long, but still super interesting, body of my also long, but also super interesting, proposal. Check it out!" }
        let(:fake_title) { "<script>alert(\"HEY\")</script> This is my title" }

        before do
          allow(helper).to receive(:proposal_path).and_return(Decidim::Proposals::ProposalPresenter.new(proposal).proposal_path)
        end

        it "returns preview data" do
          allow(proposal).to receive(:body).and_return(en: fake_body)
          allow(proposal).to receive(:title).and_return(en: fake_title)

          expect(subject["latitude"]).to eq(latitude)
          expect(subject["longitude"]).to eq(longitude)
          expect(subject["address"]).to eq(address)
          expect(subject["title"]).to eq("&lt;script&gt;alert(&quot;HEY&quot;)&lt;/script&gt; This is my title")
          expect(subject["body"]).to eq("<div class=\"ql-editor ql-reset-decidim\">alert(&quot;HEY&quot;) This is my long, but still super interesting, body of my also long, but also super inte...</div>")
          expect(subject["link"]).to eq(Decidim::Proposals::ProposalPresenter.new(proposal).proposal_path)
          expect(subject["icon"]).to match(/<svg.+/)
        end
      end

      describe "#proposals_data_for_map" do
        subject { helper.proposals_data_for_map(proposals) }

        before do
          allow(helper).to receive(:proposal_path).and_return(Decidim::Proposals::ProposalPresenter.new(proposal).proposal_path)
        end

        it "returns preview data" do
          expect(subject.length).to eq(5)
        end
      end
    end
  end
end
