# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::UserRenderer do
    let(:user) { create(:user, :confirmed) }
    let(:renderer) { described_class.new(content) }
    let(:presenter) { Decidim::UserPresenter.new(user) }

    context "when content has a valid Decidim::User Global ID" do
      let(:content) { "This text contains a valid Decidim::User Global ID: #{user.to_global_id}" }

      it "renders the mention" do
        expect(renderer.render).to eq(%(This text contains a valid Decidim::User Global ID: <a class="user-mention" href="/profiles/#{user.nickname}">@#{user.nickname}</a>))
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
  end
end
