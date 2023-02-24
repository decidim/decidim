# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe ApplicationHelper do
      describe "#render_meeting_body" do
        subject { helper.render_meeting_body(meeting) }

        before do
          allow(helper).to receive(:present).with(meeting).and_return(Decidim::Meetings::MeetingPresenter.new(meeting))
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
              <<~HTML.strip
                <div class="ql-editor ql-reset-decidim"><ul>
                <li>First</li>
                <li>Second</li>
                <li>Third</li>
                </ul>alert('OK');</div>
              HTML
            )
          end
        end
      end
    end
  end
end
