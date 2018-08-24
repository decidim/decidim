# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::HashtagRenderer do
    let(:hashtag) { create(:hashtag) }
    let(:renderer) { described_class.new(content) }
    let(:presenter) { Decidim::HashtagPresenter.new(hashtag) }

    context "when content has a valid Decidim::Hashtag Global ID" do
      let(:content) { "This text contains a valid Decidim::Hashtag Global ID: #{hashtag.to_global_id}" }

      it "renders the hashtagging" do
        expect(renderer.render).to eq(%(This text contains a valid Decidim::Hashtag Global ID: <a target="_blank" class="hashtag-mention" href="/search?term=%23#{hashtag.name}">##{hashtag.name}</a>))
      end
    end

    context "when content has an unparsed hashtag" do
      let(:content) { "This text mentions a non valid hashtag: #unvalid" }

      it "ignores the hashtag mention" do
        expect(renderer.render).to eq(content)
      end
    end
  end
end
