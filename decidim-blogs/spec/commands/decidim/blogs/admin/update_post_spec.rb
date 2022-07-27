# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe UpdatePost do
        subject { described_class.new(form, post, current_user) }

        let(:organization) { create(:organization) }
        let(:participatory_process) { create :participatory_process, organization: }
        let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "blogs" }
        let(:current_user) { create :user, organization: }
        let(:title) { "Post title" }
        let(:body) { "Lorem Ipsum dolor sit amet" }
        let(:post) { create(:post, component: current_component, author: current_user) }
        let(:invalid) { false }
        let(:form) do
          double(
            invalid?: invalid,
            title: { en: title },
            body: { en: body },
            current_component:,
            author: current_user
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "doesn't update the post" do
            expect(post).not_to receive(:update!)
            subject.call
          end
        end

        context "when everything is ok" do
          let(:title) { "Post title updated" }
          let(:body) { "Lorem Ipsum dolor sit amet updated" }

          it "updates the title" do
            subject.call
            expect(translated(post.title)).to eq title
          end

          it "updates the body" do
            subject.call
            expect(translated(post.body)).to eq body
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "creates a searchable resource" do
            expect { subject.call }.to change(Decidim::SearchableResource, :count).by_at_least(1)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(post, current_user, {
                      title: { en: title },
                      body: { en: body },
                      author: current_user
                    })
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)

            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.version.event).to eq "update"
          end

          context "with a group author" do
            let(:group) { create(:user_group, :verified, organization:) }
            let(:form) do
              double(
                invalid?: invalid,
                title: { en: title },
                body: { en: body },
                current_component:,
                author: group
              )
            end

            it "sets the group as the author" do
              subject.call
              expect(post.author).to eq(group)
            end
          end
        end
      end
    end
  end
end
