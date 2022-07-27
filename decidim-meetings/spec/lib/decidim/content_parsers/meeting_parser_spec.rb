# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ContentParsers
    describe MeetingParser do
      let(:organization) { create(:organization, host: "my.host") }
      let(:component) { create(:meeting_component, organization:) }
      let(:context) { { current_organization: organization } }
      let!(:parser) { Decidim::ContentParsers::MeetingParser.new(content, context) }

      describe "ContentParser#parse is invoked" do
        let(:content) { "" }

        it "must call MeetingParser.parse" do
          allow(described_class).to receive(:new).with(content, context).and_return(parser)

          result = Decidim::ContentProcessor.parse(content, context)

          expect(result.rewrite).to eq ""
          expect(result.metadata[:meeting].class).to eq Decidim::ContentParsers::MeetingParser::Metadata
        end
      end

      describe "on parse" do
        subject { parser.rewrite }

        context "when content is nil" do
          let(:content) { nil }

          it { is_expected.to eq("") }
        end

        context "when content is empty string" do
          let(:content) { "" }

          it { is_expected.to eq("") }
        end

        context "when content has no links" do
          let(:content) { "whatever content with @mentions but no links." }

          it { is_expected.to eq(content) }
        end

        context "when content has a link with a different host" do
          let(:meeting) { create(:meeting, component:) }
          let(:content) do
            url = changed_meeting_url(meeting)
            "This content references meeting #{url}."
          end

          it { is_expected.to eq("This content references meeting #{changed_meeting_url(meeting)}.") }
        end

        context "when content links to an organization different from current" do
          let(:meeting) { create(:meeting, component:) }
          let(:other_component) { create(:meeting_component, organization: create(:organization)) }
          let(:external_meeting) { create(:meeting, component: other_component) }
          let(:content) do
            url = meeting_url(external_meeting)
            "This content references meeting #{url}."
          end

          it { is_expected.to eq(content) }
        end

        context "when content has one link" do
          let(:meeting) { create(:meeting, component:) }
          let(:content) do
            url = meeting_url(meeting)
            "This content references meeting #{url}."
          end

          it { is_expected.to eq("This content references meeting #{meeting.to_global_id}.") }
        end

        context "when content has one link that is a simple domain" do
          let(:link) { "aaa:bbb" }
          let(:content) do
            "This content contains #{link} which is not a URI."
          end

          it { is_expected.to eq(content) }
        end

        context "when content has many links" do
          let(:meeting1) { create(:meeting, component:) }
          let(:meeting2) { create(:meeting, component:) }
          let(:meeting3) { create(:meeting, component:) }
          let(:content) do
            url1 = meeting_url(meeting1)
            url2 = meeting_url(meeting2)
            url3 = meeting_url(meeting3)
            "This content references the following meetings: #{url1}, #{url2} and #{url3}. Great?I like them!"
          end

          it { is_expected.to eq("This content references the following meetings: #{meeting1.to_global_id}, #{meeting2.to_global_id} and #{meeting3.to_global_id}. Great?I like them!") }
        end

        context "when content has a link that is not in a meeting component" do
          let(:meeting) { create(:meeting, component:) }
          let(:content) do
            url = meeting_url(meeting).sub(%r{/meetings/}, "/something-else/")
            "This content references a non-meeting with same ID as a meeting #{url}."
          end

          it { is_expected.to eq(content) }
        end

        context "when content has words similar to links but not links" do
          let(:similars) do
            %w(AA:aaa AA:sss aa:aaa aa:sss aaa:sss aaaa:sss aa:ssss aaa:ssss)
          end
          let(:content) do
            "This content has similars to links: #{similars.join}. Great! Now are not treated as links"
          end

          it { is_expected.to eq(content) }
        end

        context "when meeting in content does not exist" do
          let(:meeting) { create(:meeting, component:) }
          let(:url) { meeting_url(meeting) }
          let(:content) do
            meeting.destroy
            "This content references meeting #{url}."
          end

          it { is_expected.to eq("This content references meeting #{url}.") }
        end

        context "when meeting is linked via ID" do
          let(:meeting) { create(:meeting, component:) }
          let(:content) { "This content references meeting ~#{meeting.id}." }

          it { is_expected.to eq("This content references meeting #{meeting.to_global_id}.") }
        end
      end

      def meeting_url(meeting)
        Decidim::ResourceLocatorPresenter.new(meeting).url
      end

      def changed_meeting_url(meeting)
        url = meeting_url(meeting)
        regex = %r{http(s)?://my.host(:[0-9]+)?/(.*)}
        url_path = regex.match(url)[3]
        "http://my.another.host/#{url_path}"
      end
    end
  end
end
