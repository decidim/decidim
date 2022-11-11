# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::UserGroupRenderer do
    let(:user_group) { create(:user_group, :confirmed) }
    let(:renderer) { described_class.new(content) }
    let(:presenter) { Decidim::UserGroupPresenter.new(user_group) }
    let(:profile_url) { "http://#{user_group.organization.host}:#{Capybara.server_port}/profiles/#{user_group.nickname}" }

    context "when content has a valid Decidim::UserGroup Global ID" do
      let(:content) { "This text contains a valid Decidim::UserGroup Global ID: #{user_group.to_global_id}" }

      it "renders the mention" do
        expect(renderer.render).to eq(%(This text contains a valid Decidim::UserGroup Global ID: <a class="user-mention" href="#{profile_url}">@#{user_group.nickname}</a>))
      end
    end

    context "when content has more than one Decidim::UserGroup Global ID" do
      let(:content) { "This text contains two valid Decidim::UserGroup Global ID: #{user_group.to_global_id} #{user_group.to_global_id}" }

      it "renders the two mentions" do
        rendered = renderer.render
        mention = %(<a class="user-mention" href="#{profile_url}">@#{user_group.nickname}</a>)
        expect(rendered.scan(mention).length).to eq(2)
      end
    end

    context "when content has an unparsed mention" do
      let(:content) { "This text mentions a non valid user_group: @unvalid" }

      it "ignores the mention" do
        expect(renderer.render).to eq(content)
      end
    end

    context "when content has an invalid Decidim::User Global ID" do
      let(:content) { "This text contains a invalid gid for removed user_group: #{user_group.to_global_id}" }

      before { user_group.destroy }

      it "removes the Global ID" do
        expect(renderer.render).to eq("This text contains a invalid gid for removed user_group: ")
      end

      it "does not raises an exception" do
        expect { renderer.render }.not_to raise_error
      end
    end

    context "when markdown is rendered" do
      let(:content) { "<p>#{user_group.to_global_id}</p><p>#{user_group.to_global_id}</p>" }

      it "ensure regex does not match across multiple gids" do
        rendered = renderer.render
        mention = %(<a class="user-mention" href="#{profile_url}">@#{user_group.nickname}</a>)
        expect(rendered.scan(mention).length).to eq(2)
      end
    end
  end
end
