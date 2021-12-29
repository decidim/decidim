# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/factories"

describe "rake decidim_comments:update_participatory_process_in_comments", type: :task do
  let(:proposal) { create(:proposal) }
  let!(:comment) { create(:comment, participatory_space: nil, commentable: proposal) }

  it "populates the participatory space" do
    expect(comment.reload.decidim_participatory_space_id).to be_nil
    task.execute
    expect(comment.reload.decidim_participatory_space_id).to eq(proposal.participatory_space.try(:id))
  end
end
