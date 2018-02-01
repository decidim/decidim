# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentParsers::UserParser do
    let(:user) { create(:user, :confirmed) }
    let(:parser) { described_class.new(content) }

    context "when mentioning a valid user" do
      let(:content) { "This text contains a valid user mention: @#{user.nickname}" }

      it "rewrites the mention" do
        expect(parser.rewrite).to eq("This text contains a valid user mention: #{user.to_global_id}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserParser::Metadata)
        expect(parser.metadata.users).to eq([user])
      end
    end

    context "when mentioning multiple valid users" do
      let(:user2) { create(:user, :confirmed) }
      let(:content) { "This text contains multiple valid user mentions: @#{user.nickname} and @#{user2.nickname}" }

      it "rewrites all mentions" do
        expect(parser.rewrite).to include("This text contains multiple valid user mentions: #{user.to_global_id} and #{user2.to_global_id}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserParser::Metadata)
        expect(parser.metadata.users).to eq([user, user2])
      end
    end

    context "when mentioning a non valid user" do
      let(:content) { "This text mentions a non @ueee valid user: @unvalid" }

      it "ignores the mention" do
        expect(parser.rewrite).to eq("This text mentions a non @ueee valid user: @unvalid")
      end

      it "returns correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserParser::Metadata)
        expect(parser.metadata.users.size).to eq(0)
      end
    end
  end
end
