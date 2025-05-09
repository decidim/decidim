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
      let(:new_debate) { described_class.new(debate) }
      let(:serialized_taxonomies) do
        { ids: taxonomies.pluck(:id) }.merge(taxonomies.to_h { |t| [t.id, t.name] })
      end

      before do
        debate.update!(taxonomies:)
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: debate.id)
        end

        it "serializes the taxonomies" do
          expect(serialized[:taxonomies]).to eq(serialized_taxonomies)
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
            let(:author) { create(:user, name: "John Doe", organization: component.organization) }
            let(:component) { create(:debates_component) }
            let!(:debate) { create(:debate, component:, author:) }

            it "serializes the user name" do
              expect(serialized[:author]).to include(name: "John Doe")
            end

            it "serializes the link to its profile" do
              expect(serialized[:author]).to include(url: profile_url(debate.author.nickname))
            end

            context "when author is deleted" do
              let(:author) { create(:user, :deleted, organization: component.organization) }
              let!(:debate) { create(:debate, component:, author:) }

              it "does not serialize the fields" do
                expect(serialized[:author]).to eq({})
              end
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

        it "serializes the number of followers" do
          expect(serialized).to include(follows_count: debate.follows_count)
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

        it "includes the created at" do
          expect(serialized).to include(created_at: debate.created_at)
        end

        it "includes the updated at" do
          expect(serialized).to include(updated_at: debate.updated_at)
        end

        it "serializes the likes" do
          expect(serialized).to include(endorsements_count: debate.endorsements_count)
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

          context "when the debate is not closed" do
            let!(:debate) { create(:debate, closed_at: nil) }

            it "does not serialize the conclusion" do
              expect(serialized[:conclusions]).to be_nil
            end

            it "does not serialize the closed at" do
              expect(serialized[:closed_at]).to be_nil
            end
          end
        end

        context "when there is a last comment" do
          let(:last_comment_by) { create(:user, name: "User") }
          let(:debate) { create(:debate, last_comment_by:) }

          it "serializes the last comment by fields" do
            expect(serialized[:last_comment_by]).to eq(
              id: last_comment_by.id,
              name: "User",
              url: profile_url(last_comment_by.nickname)
            )
          end

          context "when the last comment is from a deleted user" do
            let(:last_comment_by) { create(:user, :deleted) }
            let(:debate) { create(:debate, last_comment_by:) }

            it "does not serialize the fields" do
              expect(serialized[:last_comment_by]).to eq({})
            end
          end
        end

        context "when there is no last comment" do
          let(:debate) { create(:debate, last_comment_by: nil) }

          it "returns no values" do
            expect(serialized[:last_comment_by]).to eq({})
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
