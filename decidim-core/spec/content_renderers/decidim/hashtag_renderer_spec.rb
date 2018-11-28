# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::HashtagRenderer do
    let(:hashtag) { create(:hashtag) }
    let(:renderer) { described_class.new(content) }
    let(:presenter) { Decidim::HashtagPresenter.new(hashtag, cased_name: name) }
    let(:name) { hashtag.name }
    let(:content) { "This text contains a valid Decidim::Hashtag Global ID: #{hashtag.to_global_id}/#{name}" }
    let(:result) { %(This text contains a valid Decidim::Hashtag Global ID: <a target="_blank" class="hashtag-mention" href="/search?term=%23#{name}">##{name}</a>) }

    it "renders the hashtagging" do
      expect(renderer.render).to eq(result)
    end

    context "when cased_name is not received" do
      let(:presenter) { Decidim::HashtagPresenter.new(hashtag) }

      it "renders the hashtagging" do
        expect(renderer.render).to eq(result)
      end
    end

    context "when parsed hashtag doesn't include the casing part" do
      let(:content) { "This text contains a valid Decidim::Hashtag Global ID: #{hashtag.to_global_id}" }

      it "renders the hashtagging" do
        expect(renderer.render).to eq(result)
      end
    end

    context "when hashtag has upper case letters" do
      let(:name) { hashtag.name.capitalize }

      it "renders the hashtagging" do
        expect(renderer.render).to eq(result)
      end
    end

    context "when content has an unparsed hashtag" do
      let(:content) { "This text mentions a non valid hashtag: #unvalid" }

      it "ignores the hashtag mention" do
        expect(renderer.render).to eq(content)
      end
    end

    context "when content has more than one Decidim::Hashtag Global ID" do
      let(:content) { "This text contains two valid Decidim::Hashtag Global ID: #{hashtag.to_global_id} #{hashtag.to_global_id}" }

      it "renders the two mentions" do
        rendered = renderer.render
        hashtag_rendered = %(<a target="_blank" class="hashtag-mention" href="/search?term=%23#{hashtag.name}">##{hashtag.name}</a>)
        expect(rendered.scan(hashtag_rendered).length).to eq(2)
      end
    end

    context "when content has an invalid Decidim::Hashtag Global ID" do
      let(:content) { "This text contains a invalid gid for removed hashtag: #{hashtag.to_global_id}" }

      before { hashtag.destroy }

      it "removes the Global ID" do
        expect(renderer.render).to eq("This text contains a invalid gid for removed hashtag: ")
      end

      it "does not raises an exception" do
        expect { renderer.render }.not_to raise_error
      end
    end

    context "when render without links" do
      context "when content is hash" do
        let(:content) { "{'en'=>'This text contains a valid Decidim::Hashtag Global ID: #{hashtag.to_global_id}','ca'=>'Aquest text conté un Decidim::Hashtag Global ID valid: #{hashtag.to_global_id}'}" }

        it "renders the hash with hashtags without_link" do
          expect(renderer.render(links: false)).to eq(%({'en'=>'This text contains a valid Decidim::Hashtag Global ID: ##{hashtag.name}','ca'=>'Aquest text conté un Decidim::Hashtag Global ID valid: ##{hashtag.name}'}))
        end
      end

      context "when content is a string" do
        let(:content) { "This text contains a valid Decidim::Hashtag Global ID: #{hashtag.to_global_id}" }

        it "renders the hashtag without_link" do
          expect(renderer.render(links: false)).to eq(%(This text contains a valid Decidim::Hashtag Global ID: ##{hashtag.name}))
        end
      end
    end
  end
end
