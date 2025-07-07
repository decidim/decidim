# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::UserRenderer do
    let(:user) { create(:user, :confirmed) }
    let(:renderer) { described_class.new(content) }
    let(:presenter) { Decidim::UserPresenter.new(user) }
    let(:profile_url) { "http://#{user.organization.host}:#{Capybara.server_port}/profiles/#{user.nickname}" }

    context "when content has a valid Decidim::User Global ID" do
      let(:content) { "This text contains a valid Decidim::User Global ID: #{user.to_global_id}" }

      it "renders the mention" do
        expect(renderer.render).to eq(%(This text contains a valid Decidim::User Global ID: <a data-external-link="false" href="#{profile_url}">@#{user.nickname}</a>))
      end
    end

    context "when content has more than one Decidim::User Global ID" do
      let(:content) { "This text contains two valid Decidim::User Global ID: #{user.to_global_id} #{user.to_global_id}" }

      it "renders the two mentions" do
        rendered = renderer.render
        mention = %(<a data-external-link="false" href="#{profile_url}">@#{user.nickname}</a>)
        expect(rendered.scan(mention).length).to eq(2)
      end
    end

    context "when content has an unparsed mention" do
      let(:content) { "This text mentions a non valid user: @unvalid" }

      it "ignores the mention" do
        expect(renderer.render).to eq(content)
      end
    end

    context "when content has an invalid Decidim::User Global ID" do
      let(:content) { "This text contains a invalid gid for removed user: #{user.to_global_id}" }

      before { user.destroy }

      it "removes the Global ID" do
        expect(renderer.render).to eq("This text contains a invalid gid for removed user: ")
      end

      it "does not raises an exception" do
        expect { renderer.render }.not_to raise_error
      end
    end

    context "when markdown is rendered" do
      let(:content) { "<p>#{user.to_global_id}</p><p>#{user.to_global_id}</p>" }

      it "ensure regex does not match across multiple gids" do
        rendered = renderer.render
        mention = %(<a data-external-link="false" href="#{profile_url}">@#{user.nickname}</a>)
        expect(rendered.scan(mention).length).to eq(2)
      end
    end

    context "when rendering for editor" do
      let(:content) { "This text contains a valid Decidim::User Global ID: #{user.to_global_id}" }
      let(:mention) { "@#{user.nickname}" }
      let(:label) { "#{mention} (#{CGI.escapeHTML(user.name)})" }

      it "renders the mention wrapper for the editor" do
        expect(renderer.render(editor: true)).to eq(
          %(This text contains a valid Decidim::User Global ID: <span data-type="mention" data-id="#{mention}" data-label="#{label}">#{label}</span>)
        )
      end
    end
  end
end
