# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe SessionType do
      include_context "with a graphql class type"

      let(:model) { current_user }

      describe "user" do
        let(:query) { "{ user { nickname } }" }

        it "returns the current user" do
          expect(response["user"]["nickname"]).to eq("@#{model.nickname}")
        end
      end

      describe "verifiedUserGroups" do
        let(:query) { "{ verifiedUserGroups { id } }" }
        let(:organization) { current_user.organization }

        let!(:creator_user_group) { create :user_group, organization:, users: [] }
        let!(:admin_user_group) { create :user_group, organization:, users: [] }
        let!(:member_user_group) { create :user_group, organization:, users: [] }
        let!(:verified_creator_user_group) { create :user_group, :verified, organization:, users: [] }
        let!(:verified_admin_user_group) { create :user_group, :verified, organization:, users: [] }
        let!(:verified_member_user_group) { create :user_group, :verified, organization:, users: [] }
        let!(:requested_user_group) { create :user_group, organization:, users: [] }

        before do
          create :user_group_membership, user: current_user, user_group: creator_user_group, role: :creator
          create :user_group_membership, user: current_user, user_group: admin_user_group, role: :admin
          create :user_group_membership, user: current_user, user_group: member_user_group, role: :member
          create :user_group_membership, user: current_user, user_group: verified_creator_user_group, role: :creator
          create :user_group_membership, user: current_user, user_group: verified_admin_user_group, role: :admin
          create :user_group_membership, user: current_user, user_group: verified_member_user_group, role: :member
          create :user_group_membership, user: current_user, user_group: requested_user_group, role: :requested
        end

        it "returns the verified user groups the user is manager of" do
          ids = response["verifiedUserGroups"].map { |group| group["id"] }

          expect(ids).to match_array([verified_admin_user_group.id, verified_creator_user_group.id].map(&:to_s))
        end
      end
    end
  end
end
