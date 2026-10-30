# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::MentionResourceRenderer do
    let(:renderer) { described_class.new(content) }
    let(:current_host) { proposal.organization.host }
    let(:proposal) { create(:proposal) }
    let(:presenter) { Decidim::ResourceLocatorPresenter.new(proposal) }
    let(:proposal_path) { presenter.path }
    let(:proposal_url) { presenter.url }
    let(:title) { proposal.presenter.title }
    let(:avatar_url) { proposal.creator.author.presenter.avatar_url(:thumb) }
    let(:content) do
      <<~HTML.squish
        <p>#{proposal.to_global_id}</p>
      HTML
    end

    before do
      ActiveStorage::Current.url_options = { host: current_host } if current_host
    end

    describe "#render" do
      subject { renderer.render }

      it "transforms GIDs to links with mentions tags" do
        fragment = Loofah.fragment(subject)
        link = fragment.at_css("p > a")

        expect(link["href"]).to eq(proposal_path)
        expect(link.at_css(".editor-mention img")["src"]).to eq(avatar_url)
        expect(link.at_css(".editor-mention span").text).to eq(title.to_s)
      end

      context "when using URLs in the editor" do
        let(:content) do
          <<~HTML.squish
            <p>#{proposal_url}</p>
          HTML
        end

        it "does nothing" do
          expect(subject).to match(%(<p>#{proposal_url}</p>))
        end
      end

      context "when GID is inside an anchor tag" do
        let(:content) do
          <<~HTML.squish
            <p><a href="#{proposal.to_global_id}">Link to GID</a></p>
          HTML
        end

        it "transforms GIDs inside anchor tags to URLs" do
          expect(subject).to match(%(<p><a href="#{proposal_url}">Link to GID</a></p>))
        end
      end

      context "when GID is inside an anchor tag in editor mode" do
        subject { renderer.render(editor: true) }

        let(:content) do
          <<~HTML.squish
            <p><a href="#{proposal.to_global_id}">Link to GID</a></p>
          HTML
        end

        it "transforms GIDs inside anchor tags to paths" do
          expect(subject).to match(%(<p><a href="#{proposal_path}">Link to GID</a></p>))
        end
      end

      context "when URLs are inside anchor tags" do
        let(:content) do
          <<~HTML.squish
            <p><a href="#{proposal_url}">Link to proposal</a></p>
          HTML
        end

        it "does not transform GIDs inside anchor tags with different href attributes" do
          expect(subject).to match(%(<p><a href="#{proposal_url}">Link to proposal</a></p>))
        end
      end

      context "when the proposal title contains HTML" do
        let(:title) { %(Check this proposal"><img src=x onerror=alert(document.cookie)>) }
        let(:proposal) { create(:proposal, title: { en: title }) }

        it "escapes the title in editor mode" do
          result = renderer.render(editor: true)

          expect(result).to include("&lt;img")
          expect(result).not_to include("<img")
        end

        it "escapes the title in rendered links" do
          result = renderer.render
          fragment = Loofah.fragment(result)

          expect(result).to include("&lt;img")
          expect(fragment.css("img[onerror]")).to be_empty
          expect(fragment.css('img[src="x"]')).to be_empty
        end
      end
    end
  end
end
