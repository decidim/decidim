# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    describe PostSerializer do
      subject do
        described_class.new(post)
      end

      let!(:post) { create(:post, component:) }
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:component) { create(:post_component, participatory_space:) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: post.id)
        end

        describe "author" do
          context "when it is a user" do
            before do
              post.author.update!(name: "John Doe")
              post.reload
            end

            it "serializes the user name" do
              expect(serialized[:author]).to include(name: "John Doe")
            end

            it "serializes the link to its profile" do
              expect(serialized[:author]).to include(url: profile_url(post.author.nickname))
            end
          end

          context "when it is a user group" do
            let!(:post) { create(:post, author:, component:) }
            let(:author) { create(:user_group, :verified, organization:) }

            before do
              post.author.update!(name: "ACME", nickname: "acme")
              post.reload
            end

            it "serializes the user name of the user group" do
              expect(serialized[:author]).to include(name: "ACME")
            end

            it "serializes the link to the profile of the user group" do
              expect(serialized[:author]).to include(url: profile_url("acme"))
            end
          end
        end

        it "serializes the title" do
          expect(serialized).to include(title: post.title)
        end

        it "serializes the body" do
          expect(serialized).to include(body: post.body)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_space.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_space.slug)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: post.component.id)
        end

        it "serializes the comments count" do
          expect(serialized).to include(comments_count: post.comments_count)
        end

        it "serializes the endorsements count" do
          expect(serialized).to include(endorsements_count: post.endorsements_count)
        end

        it "serializes the follows count" do
          expect(serialized).to include(follows_count: post.follows_count)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", post.id.to_s)
        end
      end

      def profile_url(nickname)
        Decidim::Core::Engine.routes.url_helpers.profile_url(nickname, host:)
      end

      def root_url
        Decidim::Core::Engine.routes.url_helpers.root_url(host:)
      end

      def host
        post.organization.host
      end
    end
  end
end
