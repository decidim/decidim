# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe Markdown2Proposals do

      def should_parse_and_produce_proposals(num_proposals)
        proposals= Decidim::Proposals::Proposal.where(component: component)
        expect { parser.parse(document) }.to change { proposals.count }.by(num_proposals)
        proposals
      end

      def should_have_expected_states(proposal)
        expect(proposal.draft?).to be true
        expect(proposal.official?).to be true
      end

      let!(:component) { create(:proposal_component) }
      let(:parser) { Markdown2Proposals.new(component)}
      let(:items) { Array.new }
      let(:document) do
        items.join("\n")
      end

      describe "titles create sections and sub-sections" do
        context "titles of level 1" do
          let(:title) { ::Faker::Book.title }
          before do
            items << "# #{title}\n"
          end

          it "create sections" do
            should_parse_and_produce_proposals(1)

            proposal= Proposal.last
            expect(proposal.title).to eq(title)
            expect(proposal.body).to eq(title)
            expect(proposal.position).to eq(1)
            expect(proposal.participatory_text_level).to eq(Proposal::PARTICIPATORY_TEXT_LEVEL[:section])
            should_have_expected_states(proposal)
          end
        end

        context "titles of deeper levels" do
          let(:titles) { (0...5).collect {|idx| "#{idx}-#{::Faker::Book.title}"} }
          before do
            titles.each_with_index { |title, idx| items << "#{'#'*(2+idx)} #{title}\n" }
          end

          it "create sub-sections" do
            expected_pos= 1

            proposals= should_parse_and_produce_proposals(5)

            proposals.order(:position).each_with_index do |proposal, idx|
              expect(proposal.title).to eq(titles[idx])
              expect(proposal.body).to eq(titles[idx])
              expect(proposal.position).to eq(expected_pos)
              expected_pos+= 1
              expect(proposal.participatory_text_level).to eq('sub-section')
              should_have_expected_states(proposal)
            end
          end
        end
      end

      describe "paragraphs create articles" do
        let(:paragraph) { ::Faker::Lorem.paragraph }
        before do
          items << "#{paragraph}\n"
        end

        it "produces a proposal like an article" do
          should_parse_and_produce_proposals(1)

          proposal= Proposal.last
          # proposal titled with its numbering (position)
          # the paragraph ans proposal's body
          expect(proposal.title).to eq("1")
          expect(proposal.body).to eq(paragraph)
          expect(proposal.position).to eq(1)
          expect(proposal.participatory_text_level).to eq(Proposal::PARTICIPATORY_TEXT_LEVEL[:article])
          should_have_expected_states(proposal)
        end
      end

      describe "images" do
        it "are ignored"
      end

    end
  end
end
