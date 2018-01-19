# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::UserRenderer do
    let(:user) { create(:user, :confirmed) }
    let(:render) { described_class.new(content) }
    let(:presenter) { Decidim::UserPresenter.new(user) }

    context "when content has a valid guid for an user" do
      let(:content) { "This text contains a valid gid for user: #{user.to_global_id}" }

      it "renders the mention" do
        expect(render.render).to include(presenter.display_mention)
      end
    end

    context "when content has a unparsed mention" do
      let(:content) { "This text mentions a non valid user: @unvalid" }

      it "ignores the mention" do
        expect(render.render).to include("@unvalid")
      end
    end

    context "when content has a invalid guid user" do
      let(:content) { "This text contains a invalid gid for removed user: #{user.to_global_id.to_s.gsub(/\d$/, "0")}" }

      it "removes the guid" do
        expect(render.render).not_to include("guid:")
      end

      it "not raises an exception" do
        expect { render.render }.not_to raise_error
      end
    end
  end
end
