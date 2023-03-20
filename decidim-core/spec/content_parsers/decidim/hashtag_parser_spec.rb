# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentParsers::HashtagParser do
    let(:organization) { create(:organization) }
    let(:hashtag) { create(:hashtag, organization:, name:) }
    let(:name) { "a_hashtag" }
    let(:context) { { current_organization: organization, extra_hashtags: } }
    let(:extra_hashtags) { false }
    let(:parser) { described_class.new(content, context) }

    let(:content) { "This text contains a hashtag present on DB: ##{hashtag.name}" }
    let(:parsed_content) { "This text contains a hashtag present on DB: #{hashtag.to_global_id}/#{hashtag.name}" }
    let(:metadata_hashtags) { [hashtag] }

    shared_examples "find and stores the hashtags references" do
      it "rewrites the hashtag" do
        expect(parser.rewrite).to eq(parsed_content)
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::HashtagParser::Metadata)
        expect(parser.metadata.hashtags).to eq(metadata_hashtags)
      end
    end

    it_behaves_like "find and stores the hashtags references"

    context "when content hashtag does not match existing case" do
      let(:content) { "This text contains a hashtag present on DB: ##{hashtag.name.upcase}" }
      let(:parsed_content) { "This text contains a hashtag present on DB: #{hashtag.to_global_id}/#{hashtag.name.upcase}" }

      it_behaves_like "find and stores the hashtags references"
    end

    context "when contents has a new hashtag" do
      let(:hashtag) { Decidim::Hashtag.find_by(organization:, name:) }
      let(:content) { "This text contains a hashtag not present on DB: ##{name}" }
      let(:parsed_content) { "This text contains a hashtag not present on DB: #{hashtag.to_global_id}/#{hashtag.name}" }

      it_behaves_like "find and stores the hashtags references"
    end

    context "when hashtagging multiple hashtags" do
      let(:new_hashtag) { Decidim::Hashtag.find_by(organization:, name: "a_new_one") }
      let(:hashtag2) { create(:hashtag, organization:) }
      let(:content) { "This text contains multiple hashtag presents: #a_new_one, ##{hashtag.name} and ##{hashtag2.name}" }
      let(:parsed_content) { "This text contains multiple hashtag presents: #{new_hashtag.to_global_id}/#{new_hashtag.name}, #{hashtag.to_global_id}/#{hashtag.name} and #{hashtag2.to_global_id}/#{hashtag2.name}" }
      let(:metadata_hashtags) { [new_hashtag, hashtag, hashtag2] }

      it_behaves_like "find and stores the hashtags references"
    end

    context "when hashtags name contains unicode characters" do
      let(:hashtag) { create(:hashtag, organization:, name: "acción_mutante") }

      it_behaves_like "find and stores the hashtags references"
    end

    context "when content contains the same new hashtag twice" do
      let(:hashtag) { Decidim::Hashtag.find_by(organization:, name:) }
      let(:content) { "This text contains a hashtag not present on DB twice: ##{name} and ##{name}" }
      let(:parsed_content) { "This text contains a hashtag not present on DB twice: #{hashtag.to_global_id}/#{hashtag.name} and #{hashtag.to_global_id}/#{hashtag.name}" }

      it_behaves_like "find and stores the hashtags references"

      context "when written with different case" do
        let(:content) { "This text contains a hashtag not present on DB twice: ##{name.downcase} and ##{name.upcase}" }
        let(:parsed_content) { "This text contains a hashtag not present on DB twice: #{hashtag.to_global_id}/#{hashtag.name.downcase} and #{hashtag.to_global_id}/#{hashtag.name.upcase}" }

        it_behaves_like "find and stores the hashtags references"
      end
    end

    context "when content contains non-hash characters next to the hashtag name" do
      let(:content) { "You cannot add some characters to hashtags: ##{hashtag.name}+extra" }
      let(:parsed_content) { "You cannot add some characters to hashtags: #{hashtag.to_global_id}/#{hashtag.name}+extra" }

      it_behaves_like "find and stores the hashtags references"
    end

    context "when parsing extra hashtags" do
      let(:extra_hashtags) { true }

      let(:content) { "This text contains a hashtag present on DB: ##{hashtag.name}" }
      let(:parsed_content) { "This text contains a hashtag present on DB: #{hashtag.to_global_id}/_#{hashtag.name}" }

      it_behaves_like "find and stores the hashtags references"
    end

    context "when the hashtag is at the beginning of the string" do
      let(:content) { "##{hashtag.name} is at the beginning of the string" }
      let(:parsed_content) { "#{hashtag.to_global_id}/#{hashtag.name} is at the beginning of the string" }

      it_behaves_like "find and stores the hashtags references"
    end

    context "when the hashtags are added through the WYSIWYG editor" do
      let(:new_hashtag) { Decidim::Hashtag.find_by(organization:, name: "a_new_one") }
      let(:hashtag2) { create(:hashtag, organization:) }
      let(:content) do
        %(<p>This text contains multiple hashtag presents: #{html_hashtag("a_new_one")}, #{html_hashtag(hashtag.name)} and #{html_hashtag(hashtag2.name)}</p>)
      end
      let(:parsed_content) { "<p>This text contains multiple hashtag presents: #{new_hashtag.to_global_id}/#{new_hashtag.name}, #{hashtag.to_global_id}/#{hashtag.name} and #{hashtag2.to_global_id}/#{hashtag2.name}</p>" }
      let(:metadata_hashtags) { [new_hashtag, hashtag, hashtag2] }

      it_behaves_like "find and stores the hashtags references"

      def html_hashtag(hashtag)
        %(<span data-type="hashtag" data-label="##{hashtag}">##{hashtag}</span>)
      end
    end

    context "when content contains an URL with a fragment (aka anchor link)" do
      let(:content) { "You can add an URL and this should not be parsed http://www.example.org/path##{hashtag.name}" }
      let(:parsed_content) { "You can add an URL and this should not be parsed http://www.example.org/path#fragment" }

      it "does not find the hashtag" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::HashtagParser::Metadata)
        expect(parser.metadata.hashtags).to eq([])
      end
    end

    context "when written with an slash before the fragment" do
      let(:content) { "You can add an URL and this should not be parsed http://www.example.org/path/#fragment" }
      let(:parsed_content) { "You can add an URL and this should not be parsed http://www.example.org/path/#fragment" }

      it "does not find the hashtag" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::HashtagParser::Metadata)
        expect(parser.metadata.hashtags).to eq([])
      end
    end
  end
end
