  # frozen_string_literal: true

  require "spec_helper"

  module Decidim
    module Blogs
      module Admin
        describe PostForm do

          subject do
            described_class.from_params(attributes).with_context(
              current_organization: current_organization
            )
          end

          let(:current_organization) { create(:organization) }
          let(:current_user) { create :user, organization: current_organization }
          let(:user_group) { create(:user_group, :verified, organization: current_organization) }

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
                "body" => body
              }
            }
          end

          context "when everything is OK" do
            it { is_expected.to be_valid }
          end

          describe "map_model" do
            let(:component) { create(:post_component, organization: current_organization) }
            let(:post) { create(:post, component: component, author: author) }
            let(:author) { create(:user, organization: current_organization) }

            before do
              subject.map_model(post)
            end

            context "when author is a user" do

              it "should assign current_user as user_group_id" do
                expect(subject.user_group_id).to eq("current_user")
              end

              it "should assign user name as author" do
                expect(subject.author).to eq(current_user)
              end

            end

            context "when author is an organization" do

              let(:author) { current_organization }

              it "should assign 'current_organization' as user_group_id" do
                expect(subject.user_group_id).to eq("current_organization")
              end

              it "should assign current_organization as author" do
                expect(subject.author).to eq(current_organization)
              end

            end

            context "when the author is a group" do

              let(:author) { create(:user_group, :verified, organization: current_organization) }

              it "should assign user_group.id as user_group_id" do
                expect(subject.user_group_id).to eq(user_group.id.to_s)#to_s to revise
              end

              it "should assign user_group.name as author" do
                expect(subject.author).to eq(user_group)
              end

            end

          end

        end

      end
    end
  end
