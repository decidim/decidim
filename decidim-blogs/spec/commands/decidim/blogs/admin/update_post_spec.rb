# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe UpdatePost do
        subject { described_class.new(form, post) }

        let(:organization) { create(:organization) }
        let(:participatory_process) { create :participatory_process, organization: organization }
        let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "blogs" }
        let(:current_user) { create :user, organization: organization }
        let(:title) { "Post title" }
        let(:body) { "Lorem Ipsum dolor sit amet" }
        let(:post) { create(:post, component: current_component, author: current_user) }
        let(:invalid) { false }
        let(:form) do
          double(
            invalid?: invalid,
            title: { en: title },
            body: { en: body },
            current_component: current_component,
            decidim_author_id: current_user.id
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "doesn't update the post" do
            expect(post).not_to receive(:update_attributes!)
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
        end
      end
    end
  end
end
