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

          it "does not assign the user group for normal users" do
            expect(subject.user_group_id).to be_nil
          end

          context "when the author is a group" do
            let(:author) { create(:user_group, :verified, organization: current_organization) }

            it "assigns the user group ID to the form" do
              expect(subject.user_group_id).to eq(author.id)
            end
          end
        end
      end
    end
  end
end
