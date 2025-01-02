# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentFormCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment_form", commentable) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create(:comment, commentable:) }

    context "when rendering" do
      context "when component comments_max_length is malformed" do
        let(:component) { create(:component, participatory_space: participatory_process, settings: { comments_max_length: "" }) }

        it { expect { subject }.not_to raise_error }
      end

      context "when organization comments_max_length is malformed" do
        let(:component) { create(:component, participatory_space: participatory_process, settings: { comments_max_length: "" }) }
        let(:organization) { create(:organization, comments_max_length: "") }

        it { expect { subject }.not_to raise_error }
      end

      it "renders the form" do
        expect(subject).to have_css("#add-comment-DummyResource-#{commentable.id}[maxlength='1000']")
        expect(subject).to have_css("#add-comment-DummyResource-#{commentable.id}-remaining-characters")
        expect(subject).to have_css("input.alignment-input[name='comment[alignment]'][value='0']", visible: :hidden)
        expect(subject).to have_field(name: "comment[commentable_gid]", type: :hidden)
        expect(subject).to have_button(text: "Publish comment", disabled: true)

        expect(subject).to have_no_css("#add-comment-DummyResource-#{commentable.id}-user-group-id")
      end

      context "with user belonging to groups" do
        let(:current_user) { create(:user, :confirmed, organization: component.organization) }

        context "when the groups are verified" do
          let!(:groups) { create_list(:user_group, 2, :verified, users: [current_user]) }

          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end

          it "renders the comment as input" do
            expect(subject).to have_css(".comment__as-author-container")

            groups.each do |group|
              expect(subject).to have_css("input[type='radio'][name='comment[user_group_id]'][value='#{group.id}']")
              expect(subject).to have_css(".comment__as-author-name", text: group.name)
            end
          end
        end

        context "when the organization has a comments_max_length setting" do
          let(:organization) { create(:organization, comments_max_length: 350) }

          it "renders the comment input with correct maxlength" do
            expect(subject).to have_css("#add-comment-DummyResource-#{commentable.id}[maxlength='350']")
          end
        end

        context "when the component has a comments_max_length setting" do
          let(:component) { create(:component, participatory_space: participatory_process, settings: { comments_max_length: 350 }) }

          it "renders the comment input with correct maxlength" do
            expect(subject).to have_css("#add-comment-DummyResource-#{commentable.id}[maxlength='350']")
          end
        end

        context "when the groups are not verified" do
          before do
            allow(controller).to receive(:current_user).and_return(current_user)

            create_list(:user_group, 2, users: [current_user])
          end

          it "does not render the comment as input" do
            expect(subject).to have_no_css("#add-comment-DummyResource-#{commentable.id}-user-group-id")
          end
        end

        describe "#two_columns_layout?" do
          before do
            allow(commentable).to receive(:respond_to?).with(:two_columns_layout?).and_return(responds_to_two_columns_layout)
            allow(commentable).to receive(:two_columns_layout?).and_return(two_columns_layout) if responds_to_two_columns_layout
          end

          context "when two_columns_layout? is true" do
            let(:responds_to_two_columns_layout) { true }
            let(:two_columns_layout) { true }

            it "returns true" do
              expect(my_cell.send(:two_columns_layout?)).to be_truthy
            end
          end

          context "when two_columns_layout? is false" do
            let(:responds_to_two_columns_layout) { true }
            let(:two_columns_layout) { false }

            it "returns false" do
              expect(my_cell.send(:two_columns_layout?)).to be_falsey
            end
          end

          context "when model does not respond to two_columns_layout?" do
            let(:responds_to_two_columns_layout) { false }

            it "returns false" do
              expect(my_cell.send(:two_columns_layout?)).to be_falsey
            end
          end
        end
      end
    end
  end
end
