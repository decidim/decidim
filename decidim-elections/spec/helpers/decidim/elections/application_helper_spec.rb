# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe ApplicationHelper do
      let(:organization) { create(:organization) }

      before do
        allow(helper).to receive(:current_organization).and_return(organization)
      end

      describe "#question_description" do
        subject(:rendered_description) { helper.render_question_description(question) }

        context "when the description is blank" do
          let(:question) { build(:election_question, description: { "en" => "" }) }

          it { is_expected.to be_nil }
        end

        context "when the description has plain text" do
          let(:question) { create(:election_question, description: { "en" => "More info" }) }

          it { is_expected.to eq('<div class="rich-text-display">More info</div>') }
        end

        context "when the description includes markup" do
          let(:question) { build(:election_question, description: { "en" => "<strong>Intro</strong>" }) }

          it "keeps the allowed tags" do
            expect(rendered_description).to eq('<div class="rich-text-display"><strong>Intro</strong></div>')
          end
        end

        context "when the description includes images" do
          let(:question) { build(:election_question, description: { "en" => '<p>Check this image:</p><img src="image.jpg" alt="Example">' }) }

          it "keeps the image tags" do
            expect(rendered_description).to include("<img")
            expect(rendered_description).to include('src="image.jpg"')
            expect(rendered_description).to include('alt="Example"')
          end
        end
      end
    end
  end
end
