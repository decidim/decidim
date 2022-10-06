# frozen_string_literal: true

require "spec_helper"

shared_examples_for "counts commentators as newsletter participants" do
  # non participant commentator (comments into other spaces)
  let!(:non_participant) { create(:user, :confirmed, newsletter_notifications_at: Time.current, organization: component_out_of_newsletter.organization) }
  # expects resource_out_of_newsletter to belong to a space which has NOT been selected in the newsletter
  let!(:outlier_comment) { create(:comment, author: non_participant, commentable: resource_out_of_newsletter) }

  let(:commentators_ids) { [] }
  let(:recipients_ids) { author_ids + commentators_ids }

  context "without commentators" do
    it "returns zero participants" do
      expect(subject).to match_array(recipients_ids)
    end
  end

  context "with commentators, counts commentators in the current space" do
    # participant commentator
    let!(:commentator_participant) { create(:user, :confirmed, newsletter_notifications_at: Time.current, organization:) }
    # expects resource_in_newsletter to belong to a space selected in the newsletter
    let!(:comment_in_newsletter) { create(:comment, author: commentator_participant, commentable: resource_in_newsletter) }
    let(:commentators_ids) { [commentator_participant.id] }

    it "returns only commenters in the selected spaces" do
      expect(subject).to match_array(recipients_ids)
    end
  end
end
