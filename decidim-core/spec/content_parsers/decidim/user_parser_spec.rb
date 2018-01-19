# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentParsers::UserParser do
    let(:user) { create(:user, :confirmed) }
    let(:parser) { described_class.new(content) }

    context "when mentioning a valid user" do
      let(:content) { "This text contains a valid user mention: @#{user.nickname}" }

      it "rewrites the mention" do
        expect(parser.rewrite).to include(user.to_global_id.to_s)
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to eq(users: [user])
      end
    end

    context "when mentioning multiple valid users" do
      let(:user2) { create(:user, :confirmed) }
      let(:content) { "This text contains multiple valid user mentions: @#{user.nickname} and @#{user2.nickname}" }

      it "rewrites all mentions" do
        expect(parser.rewrite).to include(user.to_global_id.to_s, user2.to_global_id.to_s)
        expect(parser.rewrite).not_to include("@#{user.nickname}", "@#{user2.nickname}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to eq(users: [user, user2])
      end
    end

    context "when mentioning a non valid user" do
      let(:content) { "This text mentions a non @ueee valid user: @unvalid" }

      it "ignores the mention" do
        expect(parser.rewrite).not_to include("gid:")
      end

      it "returns correct metada" do
        expect(parser.metadata).to eq(users: [])
      end
    end
  end
end
