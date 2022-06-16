# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ContentRenderers
    describe MeetingRenderer do
      let!(:renderer) { Decidim::ContentRenderers::MeetingRenderer.new(content) }

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

        context "when content has no gids" do
          let(:content) { "whatever content with @mentions but no gids." }

          it { is_expected.to eq(content) }
        end

        context "when content has one gid" do
          let(:meeting) { create(:meeting) }
          let(:content) do
            "This content references meeting #{meeting.to_global_id}."
          end

          it { is_expected.to eq("This content references meeting #{resource_as_html_link(meeting)}.") }
        end

        context "when content has many links" do
          let(:meeting1) { create(:meeting) }
          let(:meeting2) { create(:meeting) }
          let(:meeting3) { create(:meeting) }
          let(:content) do
            gid1 = meeting1.to_global_id
            gid2 = meeting2.to_global_id
            gid3 = meeting3.to_global_id
            "This content references the following proposals: #{gid1}, #{gid2} and #{gid3}. Great?I like them!"
          end

          it { is_expected.to eq("This content references the following proposals: #{resource_as_html_link(meeting1)}, #{resource_as_html_link(meeting2)} and #{resource_as_html_link(meeting3)}. Great?I like them!") }
        end
      end

      def resource_url(resource)
        Decidim::ResourceLocatorPresenter.new(resource).path
      end

      def resource_as_html_link(resource)
        href = resource_url(resource)
        title = translated(resource.title)
        %(<a href="#{href}">#{title}</a>)
      end
    end
  end
end
