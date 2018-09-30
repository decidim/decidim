# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe Markdown2Proposals do

      def should_have_expected_states(proposal)
        expect(proposal.draft?).to be_true
        expect(proposal.official?).to be_true
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
            parser.parse(document)

            proposal= Proposal.last
            expect(proposal.title).to eq(title)
            expect(proposal.body).to eq(title)
            expect(proposal.position).to eq(1)
            expect(proposal.participatory_text_type).to eq('section')
            should_have_expected_states(proposal)
          end
        end

        context "titles of deeper levels" do
          it "create sub-sections" do
            expected_pos= 1

            proposals= Decidim::Proposals::Proposal.where(component: component)
            proposals.each_with_index do |p, idx|
              expect(p.title).to eq(titles[idx])
              expect(p.body).to be_empty
              expect(p.position).to eq(expected_pos)
              expected_pos+= 1
              expect(p.participatory_text_type).to eq('sub-section')
              should_have_expected_states(proposal)
            end
          end
        end
      end

      describe "paragraphs create articles" do
        let(:paragraph) { Faker.paragraph }
        it "produces an article like proposal" do
          # proposal titled with its numbering (position)
          expect(proposal.title).to eq(1)
          # the paragraph ans proposal's body
          expect(proposal.body).to eq(paragraph)
          should_have_expected_states(proposal)
        end
      end

      describe "images" do
        it "are ignored"
      end

    end
  end
end
