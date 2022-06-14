# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe PostForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization,
            current_user: current_user
          )
        end

        let(:current_organization) { create(:organization) }
        let(:current_user) { create :user, organization: current_organization }
        let(:another_user) { create(:user, organization: current_organization) }
        let(:user_group) { create(:user_group, :verified, organization: current_organization) }
        let(:decidim_author_id) { "" }
        let(:component) { create(:post_component, organization: current_organization) }
        let(:post) { create(:post, component: component, author: author) }
        let(:user_from_another_org) { create(:user) }
        let(:post_id) { nil }

        let(:title) do
          {
            "en" => "Title",
            "ca" => "Títol",
            "es" => "Título"
          }
        end

        let(:body) do
          {
            "en" => "<p>Content</p>",
            "ca" => "<p>Contingut</p>",
            "es" => "<p>Contenido</p>"
          }
        end

        let(:attributes) do
          {
            "post" => {
              "title" => title,
              "body" => body,
              "decidim_author_id" => decidim_author_id,
              "id" => post_id
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when title is missing" do
          let(:title) do
            { "en" => "" }
          end

          it { is_expected.to be_invalid }
        end

        context "when body is missing" do
          let(:body) do
            { "en" => "" }
          end

          it { is_expected.to be_invalid }
        end

        context "when organization is specified" do
          let(:decidim_author_id) { current_organization.id }

          it { is_expected.to be_valid }
        end

        context "when author is a current_user" do
          let(:decidim_author_id) { current_user.id }

          it { is_expected.to be_valid }

          it "assigns current_user as author" do
            expect(subject.author).to eq(current_user)
          end
        end

        context "when the author belongs to different organization" do
          let(:decidim_author_id) { user_from_another_org.id }

          it "sets the author to the current_organization" do
            expect(subject.author).to eq(current_organization)
          end
        end

        context "when decidim_author_id is empty" do
          it "assigns current_organization as author" do
            expect(subject.author).to eq(current_organization)
          end
        end

        context "when decidim_author_id is user_group" do
          let(:decidim_author_id) { user_group.id }

          it "assigns user_group as author" do
            expect(subject.author).to eq(user_group)
          end
        end

        context "when decidim_author_id is another_user from the same organization" do
          let(:post_id) { post.id }
          let(:author) { current_user }
          let(:decidim_author_id) { another_user.id }

          it { is_expected.to be_invalid }
        end

        describe "when assigns a model" do
          subject do
            described_class.from_model(post).with_context(
              current_organization: current_organization,
              current_user: current_user
            )
          end

          let(:author) { current_organization }

          context "when author is an organization" do
            it "assigns current_organization.id as decidim_author_id" do
              expect(subject.decidim_author_id).to be_nil
            end

            it "assigns current_organization as author" do
              expect(subject.author).to eq(current_organization)
            end
          end

          context "when the author is a group" do
            let(:author) { user_group }

            it "assigns user_group.id as decidim_author_id" do
              expect(subject.decidim_author_id).to eq(user_group.id)
            end

            it "assigns user_group as author" do
              expect(subject.author).to eq(user_group)
            end
          end

          context "when the author is the current_user" do
            let(:author) { current_user }

            it "assigns current_user.id as decidim_author_id" do
              expect(subject.decidim_author_id).to eq(current_user.id)
            end

            it "assigns current_user object as author" do
              expect(subject.author).to eq(current_user)
            end
          end

          context "when the author is another user" do
            let(:author) { another_user }

            it "assigns another_user.id as decidim_author_id" do
              expect(subject.decidim_author_id).to eq(another_user.id)
            end

            it "assigns another_user object as author" do
              expect(subject.author).to eq(another_user)
            end
          end
        end
      end
    end
  end
end
