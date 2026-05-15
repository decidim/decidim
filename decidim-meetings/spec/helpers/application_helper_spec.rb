# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe ApplicationHelper do
      describe "#render_meeting_body" do
        subject { helper.render_meeting_body(meeting) }

        before do
          allow(helper).to receive(:present).with(meeting, presenter_class: nil).and_return(Decidim::Meetings::MeetingPresenter.new(meeting))
          allow(helper).to receive(:current_organization).and_return(meeting.organization)
          helper.instance_variable_set(:@meeting, meeting)
        end

        let(:description) { "<ul><li>First</li><li>Second</li><li>Third</li></ul><script>alert('OK');</script>" }
        let(:meeting_trait) { :not_official }
        let(:meeting) { create(:meeting, meeting_trait, description: { "en" => description }) }

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

        context "with official meeting" do
          let(:meeting_trait) { :official }

          it "renders a sanitized body" do
            expect(subject).to eq(
              <<~HTML.sub(/\n$/, "")
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
