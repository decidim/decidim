# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe DebateSerializer do
      subject do
        described_class.new(debate)
      end

      let!(:debate) { create(:debate) }
      let!(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization: component.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { debate.component }

      before do
        debate.update!(taxonomies:)
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: debate.id)
        end

        it "serializes the taxonomies" do
          expect(serialized[:taxonomies].length).to eq(2)
          expect(serialized[:taxonomies][:id]).to match_array(taxonomies.map(&:id))
          expect(serialized[:taxonomies][:name]).to match_array(taxonomies.map(&:name))
        end

        describe "author" do
          context "when it is an official debate" do
            let!(:debate) { create(:debate, :official) }

            before do
              component.participatory_space.organization.update!(name: { en: "My organization" })
              debate.reload
            end

            it "serializes the organization name" do
              expect(serialized[:author]).to include(name: "My organization")
            end

            it "serializes the link to the organization" do
              expect(serialized[:author]).to include(url: root_url)
            end
          end

          context "when it is a user" do
            let!(:debate) { create(:debate, :participant_author) }

            before do
              debate.author.update!(name: "John Doe")
              debate.reload
            end

            it "serializes the user name" do
              expect(serialized[:author]).to include(name: "John Doe")
            end

            it "serializes the link to its profile" do
              expect(serialized[:author]).to include(url: profile_url(debate.author.nickname))
            end
          end

          context "when it is a user group" do
            let!(:debate) { create(:debate, :user_group_author) }

            before do
              debate.author.update!(name: "ACME", nickname: "acme")
              debate.reload
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
          expect(serialized).to include(title: debate.title)
        end

        it "serializes the description" do
          expect(serialized).to include(description: debate.description)
        end

        it "serializes the start time" do
          expect(serialized).to include(start_time: debate.start_time)
        end

        it "serializes the end time" do
          expect(serialized).to include(end_time: debate.end_time)
        end

        it "serializes the information updates" do
          expect(serialized).to include(information_updates: debate.information_updates)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: debate.component.id)
        end

        it "serializes the reference" do
          expect(serialized).to include(reference: debate.reference)
        end

        it "serializes the comments" do
          expect(serialized).to include(comments: debate.comments_count)
        end

        it "serializes the followers" do
          expect(serialized).to include(followers: debate.follows.size)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", debate.id.to_s)
        end

        it "serializes the last comment at" do
          expect(serialized).to include(last_comment_at: debate.last_comment_at)
        end

        it "serializes the comments enabled" do
          expect(serialized).to include(comments_enabled: debate.comments_enabled)
        end

        describe "conclusions and closed at" do
          it "does not serializes the conclusion" do
            expect(serialized[:conclusions]).to be_nil
          end

          it "does not serializes the closed at" do
            expect(serialized[:closed_at]).to be_nil
          end

          context "when the debate is closed" do
            let!(:debate) { create(:debate, :closed) }

            it "serializes the conclusion" do
              expect(serialized).to include(conclusions: debate.conclusions)
            end

            it "serializes the closed at" do
              expect(serialized).to include(closed_at: debate.closed_at)
            end
          end
        end
      end

      def profile_url(nickname)
        Decidim::Core::Engine.routes.url_helpers.profile_url(nickname, host:, port: Capybara.server_port)
      end

      def root_url
        Decidim::Core::Engine.routes.url_helpers.root_url(host:)
      end

      def host
        debate.organization.host
      end
    end
  end
end
