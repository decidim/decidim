# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentParsers::UserParser do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:context) { { current_organization: organization } }
    let(:parser) { described_class.new(content, context) }

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

    context "when mentioning an existing user outside current organization" do
      let(:user) { create(:user, :confirmed, organization: create(:organization)) }
      let(:content) { "This text mentions a user outside current organization: @#{user.nickname}" }

      it "ignores the mention" do
        expect(parser.rewrite).to eq("This text mentions a user outside current organization: @#{user.nickname}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserParser::Metadata)
        expect(parser.metadata.users).to eq([])
      end
    end

    context "when mentioning multiple valid users" do
      let(:user2) { create(:user, :confirmed, organization: organization) }
      let(:content) { "This text contains multiple valid user mentions: @#{user.nickname} and @#{user2.nickname}" }

      it "rewrites all mentions" do
        expect(parser.rewrite).to eq("This text contains multiple valid user mentions: #{user.to_global_id} and #{user2.to_global_id}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserParser::Metadata)
        expect(parser.metadata.users).to match_array([user, user2])
      end
    end

    context "when mentioning a non valid user" do
      let(:content) { "This text mentions a non @ueee valid user: @unvalid" }

      it "ignores the mention" do
        expect(parser.rewrite).to eq("This text mentions a non @ueee valid user: @unvalid")
      end

      it "returns correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserParser::Metadata)
        expect(parser.metadata.users).to eq([])
      end
    end

    context "when mentioning a user with a wrong case" do
      let(:content) { "This text mentions a user with wrong case : @#{user.nickname.upcase}" }

      it "rewrite the good user" do
        expect(parser.rewrite).to eq("This text mentions a user with wrong case : #{user.to_global_id}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserParser::Metadata)
        expect(parser.metadata.users).to eq([user])
      end
    end
  end
end
