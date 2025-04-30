# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe ApplicationHelper do
      describe "#render_debate_description" do
        subject { helper.render_debate_description(debate) }

        before do
          allow(helper).to receive(:present).with(debate, presenter_class: nil).and_return(Decidim::Debates::DebatePresenter.new(debate))
          allow(helper).to receive(:current_organization).and_return(debate.organization)
          allow(helper).to receive(:debate).and_return(debate)
        end

        let(:description) { "<ul><li>First</li><li>Second</li><li>Third</li></ul><script>alert('OK');</script>" }
        let(:debate_trait) { :participant_author }
        let(:debate) { create(:debate, debate_trait, description: { "en" => description }) }

        it "renders a sanitized body" do
          expect(subject).to eq(
            <<~HTML.strip
              <div>• First
              <br />• Second
              <br />• Third
              </div>
            HTML
          )
        end

        context "with official debate" do
          let(:debate_trait) { :official }

          it "renders a sanitized body" do
            expect(subject).to eq(
              <<~HTML.strip
                <div class="rich-text-display">
                <ul>
                <li>First</li>
                <li>Second</li>
                <li>Third</li>
                </ul>alert('OK');</div>
              HTML
            )
          end

          context "when the description includes images and iframes" do
            let(:description) do
              <<~HTML.strip
                <p><img src="/path/to/image.jpg" alt="Image"></p>
                <div class="editor-content-videoEmbed">
                  <div>
                    <iframe src="https://example.org/video/xyz" title="Video" frameborder="0" allowfullscreen="true"></iframe>
                  </div>
                </div>
              HTML
            end

            it "renders the image and iframe embed" do
              expect(subject).to eq(
                <<~HTML.strip
                  <div class="rich-text-display">
                  <p><img src="/path/to/image.jpg" alt="Image"></p>
                  <div class="editor-content-videoEmbed">
                    <div>
                      <div class="disabled-iframe"><!-- <iframe src="https://example.org/video/xyz" title="Video" frameborder="0" allowfullscreen="true" scrolling="no"></iframe> --></div>
                    </div>
                  </div>
                  </div>
                HTML
              )
            end
          end
        end
      end
    end
  end
end
