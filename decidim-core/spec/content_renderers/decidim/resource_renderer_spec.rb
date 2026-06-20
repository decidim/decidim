# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::ResourceRenderer do
    let(:renderer_class) do
      Class.new(described_class) do
        def regex
          %r{gid://[\w-]+/Decidim::User/\d+}
        end
      end
    end

    let(:user) { create(:user) }
    let(:renderer) { renderer_class.new(content) }
    let(:profile_path) { Decidim::UserPresenter.new(user).profile_path }

    describe "#render" do
      context "when content has a valid resource GID" do
        let(:content) { "User mentioned: #{user.to_global_id}" }

        it "renders the resource mention" do
          rendered = renderer.render
          expect(rendered).to include(user.nickname)
        end
      end

      context "when resource GID is inside a code tag" do
        let(:content) do
          "<code>#{user.to_global_id}</code>"
        end

        it "does not replace resource GID inside code tags" do
          rendered = Loofah.fragment(renderer.render)
          code = rendered.at_css("code")

          expect(code.text).to eq(user.to_global_id.to_s)
        end
      end

      context "when resource GID is inside a pre tag" do
        let(:content) do
          "<pre>#{user.to_global_id}</pre>"
        end

        it "does not replace resource GID inside pre tags" do
          rendered = Loofah.fragment(renderer.render)
          pre = rendered.at_css("pre")

          expect(pre.text).to eq(user.to_global_id.to_s)
        end
      end

      context "when resource GID is inside an anchor href" do
        let(:content) do
          "<a href=\"#{user.to_global_id}\">User link</a>"
        end

        it "converts resource GID in href to profile path" do
          rendered = Loofah.fragment(renderer.render)
          link = rendered.at_css("a")

          expect(link["href"]).to eq(profile_path)
        end
      end

      context "when resource GID is invalid" do
        let(:content) { "Invalid user: gid://app/Decidim::User/999999" }

        it "replaces with tilde notation" do
          rendered = renderer.render
          expect(rendered).to include("~999999")
        end
      end
    end
  end
end
