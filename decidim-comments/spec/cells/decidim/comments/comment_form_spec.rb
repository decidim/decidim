# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentFormCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment_form", commentable) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create(:comment, commentable:) }

    context "when rendering" do
      it "renders the form" do
        expect(subject).to have_css(".hashtags__container textarea#add-comment-DummyResource-#{commentable.id}[maxlength='1000']")
        expect(subject).to have_css("#add-comment-DummyResource-#{commentable.id}-remaining-characters")
        expect(subject).to have_css("input.alignment-input[name='comment[alignment]'][value='0']", visible: :hidden)
        expect(subject).to have_css("input[name='comment[commentable_gid]']", visible: :hidden)
        expect(subject).to have_css("button", text: "Send")

        expect(subject).not_to have_css("#add-comment-DummyResource-#{commentable.id}-user-group-id")
      end

      context "with user belonging to groups" do
        let(:current_user) { create(:user, :confirmed, organization: component.organization) }

        context "when the groups are verified" do
          let!(:groups) { create_list(:user_group, 2, :verified, users: [current_user]) }

          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end

          it "renders the comment as input" do
            expect(subject).to have_css("#add-comment-DummyResource-#{commentable.id}-user-group-id")

            groups.each do |group|
              expect(subject).to have_css("#add-comment-DummyResource-#{commentable.id}-user-group-id option[value='#{group.id}']", text: group.name)
            end
          end
        end

        context "when the organization has a comments_max_length setting" do
          let(:organization) { create(:organization, comments_max_length: 350) }

          it "renders the comment input with correct maxlength" do
            expect(subject).to have_css(".hashtags__container textarea#add-comment-DummyResource-#{commentable.id}[maxlength='350']")
          end
        end

        context "when the component has a comments_max_length setting" do
          let(:component) { create(:component, participatory_space: participatory_process, settings: { comments_max_length: 350 }) }

          it "renders the comment input with correct maxlength" do
            expect(subject).to have_css(".hashtags__container textarea#add-comment-DummyResource-#{commentable.id}[maxlength='350']")
          end
        end

        context "when the groups are not verified" do
          before do
            allow(controller).to receive(:current_user).and_return(current_user)

            create_list(:user_group, 2, users: [current_user])
          end

          it "does not render the comment as input" do
            expect(subject).not_to have_css("#add-comment-DummyResource-#{commentable.id}-user-group-id")
          end
        end
      end
    end
  end
end
