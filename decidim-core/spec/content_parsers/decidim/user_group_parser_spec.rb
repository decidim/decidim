# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentParsers::UserGroupParser do
    let(:organization) { create(:organization) }
    let(:user_group) { create(:user_group, :confirmed, organization:) }
    let(:context) { { current_organization: organization } }
    let(:parser) { described_class.new(content, context) }

    context "when mentioning a valid group" do
      let(:content) { "This text contains a valid group mention: @#{user_group.nickname}" }

      it "rewrites the mention" do
        expect(parser.rewrite).to eq("This text contains a valid group mention: #{user_group.to_global_id}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserGroupParser::Metadata)
        expect(parser.metadata.groups).to eq([user_group])
      end
    end

    context "when mentioning an existing group outside current organization" do
      let(:user_group) { create(:user_group, :confirmed, organization: create(:organization)) }
      let(:content) { "This text mentions a group outside current organization: @#{user_group.nickname}" }

      it "ignores the mention" do
        expect(parser.rewrite).to eq("This text mentions a group outside current organization: @#{user_group.nickname}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserGroupParser::Metadata)
        expect(parser.metadata.groups).to eq([])
      end
    end

    context "when mentioning multiple valid groups" do
      let(:user_group2) { create(:user_group, :confirmed, organization:) }
      let(:content) { "This text contains multiple valid group mentions: @#{user_group.nickname} and @#{user_group2.nickname}" }

      it "rewrites all mentions" do
        expect(parser.rewrite).to eq("This text contains multiple valid group mentions: #{user_group.to_global_id} and #{user_group2.to_global_id}")
      end

      it "returns the correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserGroupParser::Metadata)
        expect(parser.metadata.groups).to match_array([user_group, user_group2])
      end
    end

    context "when mentioning a non valid group" do
      let(:content) { "This text mentions a non @ueee valid group: @unvalid" }

      it "ignores the mention" do
        expect(parser.rewrite).to eq("This text mentions a non @ueee valid group: @unvalid")
      end

      it "returns correct metadata" do
        expect(parser.metadata).to be_a(Decidim::ContentParsers::UserGroupParser::Metadata)
        expect(parser.metadata.groups).to eq([])
      end
    end
  end
end
