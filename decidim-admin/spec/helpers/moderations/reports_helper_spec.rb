# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/factories"

module Decidim
  module Admin
    module Moderations
      describe ReportsHelper do
        subject do
          Nokogiri::HTML(
            helper.reportable_author_name(reportable)
          )
        end

        before do
          allow(helper).to receive(:current_or_new_conversation_path_with).and_return("/conversations/1")
        end

        context "with different reportable authors types" do
          describe "when it is a dummy resource author" do
            let(:reportable) { create(:dummy_resource, title: { "en" => "<p>Dummy<br> Title</p>" }) }

            it "returns the author's name" do
              expect(helper.reportable_author_name(reportable)).to include("reportable-authors")
              expect(helper.reportable_author_name(reportable)).to include(reportable.author.name)
            end
          end

          describe "when it is a user author" do
            let!(:proposal) { create(:proposal) }
            let(:reportable) { proposal }

            it "returns the user's name" do
              expect(helper.reportable_author_name(reportable)).to include("reportable-authors")
              expect(helper.reportable_author_name(reportable)).to include(reportable.authors.first.name)
            end
          end

          describe "when it is a meeting author" do
            let!(:proposal) { create(:proposal, :official_meeting) }
            let(:reportable) { proposal }

            it "returns the meeting's title" do
              meeting_title = ActionView::Base.full_sanitizer.sanitize(translated_attribute(reportable.authors.first.title))
              expect(helper.reportable_author_name(reportable)).to include("reportable-authors")
              expect(helper.reportable_author_name(reportable)).to include(meeting_title)
            end
          end
        end
      end
    end
  end
end
