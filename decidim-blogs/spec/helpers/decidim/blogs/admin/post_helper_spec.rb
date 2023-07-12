# frozen_string_literal: true

require "spec_helper"

module Decidim::Blogs::Admin
  describe PostsHelper, type: :helper do
    include Decidim::DisabledRedesignLayout

    describe "#post_author_select_field" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let!(:another_user) { create(:user, :admin, :confirmed, organization:) }
      let!(:user_group) { create(:user_group, :verified, decidim_organization_id: organization.id, users: [user]) }
      let!(:another_user_group) { create(:user_group, :verified, decidim_organization_id: organization.id, users: [another_user]) }
      let(:name) { "a-select-form-name" }
      let(:author) { user }
      let(:form) do
        double(
          object: double(author:)
        )
      end

      let(:all_fields) do
        [
          [organization.name, ""],
          [user.name, user.id],
          [user_group.name, user_group.id]
        ]
      end

      let(:extra_user_fields) do
        [
          [organization.name, ""],
          [user.name, user.id],
          [user_group.name, user_group.id],
          [another_user.name, another_user.id]
        ]
      end

      let(:extra_group_fields) do
        [
          [organization.name, ""],
          [user.name, user.id],
          [user_group.name, user_group.id],
          [another_user_group.name, another_user_group.id]
        ]
      end

      let(:basic_fields) do
        [
          [organization.name, ""],
          [user.name, user.id]
        ]
      end

      let(:groups_enabled) { true }

      before do
        allow(helper).to receive(:current_organization).and_return(organization)
        allow(helper).to receive(:current_user).and_return(user)
        allow(organization).to receive(:user_groups_enabled?).and_return(groups_enabled)
        allow(form).to receive(:select) { |_, array| array }
      end

      context "when all actors are present" do
        it "Returns all types of authors" do
          expect(helper.post_author_select_field(form, name)).to eq(all_fields)
        end
      end

      context "when author is a user's user_group" do
        let(:author) { user_group }

        it "Returns all types of authors" do
          expect(helper.post_author_select_field(form, name)).to eq(all_fields)
        end
      end

      context "when organization has no groups_enabled" do
        let(:groups_enabled) { false }

        it "Returns organization and user" do
          expect(helper.post_author_select_field(form, name)).to eq(basic_fields)
        end

        context "when author is a user's user_group" do
          let(:author) { user_group }

          it "Returns organization, user and user group" do
            expect(helper.post_author_select_field(form, name)).to eq(all_fields)
          end
        end
      end

      context "when author is another user" do
        let(:author) { another_user }

        it "Returns all types of authors plus the original author" do
          expect(helper.post_author_select_field(form, name)).to eq(extra_user_fields)
        end
      end

      context "when author is the organization" do
        let(:author) { organization }

        it "Returns all types of authors" do
          expect(helper.post_author_select_field(form, name)).to eq(all_fields)
        end
      end

      context "when author is another user_group" do
        let(:author) { another_user_group }

        it "Returns all types of authors" do
          expect(helper.post_author_select_field(form, name)).to eq(extra_group_fields)
        end
      end
    end

    describe "#publish_data" do
      let!(:created_at) { 3.days.ago }
      let(:formatted_created_time) { created_at.strftime("%d/%m/%Y %H:%M") }

      context "when published_at is reached" do
        let(:published_at) { 2.days.ago }
        let(:formatted_published_time) { published_at.strftime("%d/%m/%Y %H:%M") }

        it "shows correct publishing info" do
          action = helper.publish_data(published_at)
          expect(action[:popup]).to be_nil
        end
      end

      context "when publish in future" do
        let(:published_at) { 2.days.from_now }
        let(:formatted_published_time) { published_at.stftime("%d/%m/%Y %H:%M") }

        it "shows correct publishing info" do
          action = helper.publish_data(published_at)
          expect(action[:popup]).to eq("Not published yet.")
          expect(action[:icon]).to include("svg")
        end
      end
    end
  end
end
