# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::AdminLog
  describe InvitePresenter, type: :helper do
    subject { described_class.new(action_log, helper).present }

    let(:participatory_space) { create :participatory_process }
    let(:component) { create :component, participatory_space: }
    let(:invite) { create(:invite, sent_at: nil) }
    let(:action_log) { create(:action_log, participatory_space:, component:, resource: invite, action: "create") }

    before do
      helper.class.include Decidim::TranslatableAttributes
    end

    describe "#present" do
      context "when invite still exists" do
        it "renders the invite information" do
          user = action_log.user
          inviter = "<a class=\"logs__log__author\" title=\"@#{user.nickname}\" data-tooltip=\"true\" data-disable-hover=\"false\" href=\"/profiles/#{user.nickname}\">#{user.name}</a>"
          space = "<a class=\"logs__log__space\" href=\"/processes/#{participatory_space.slug}?participatory_process_slug=#{participatory_space.slug}\">#{translated(participatory_space.title)}</a>"
          action_string = "#{inviter} invited #{invite.user.name} to join <span class=\"logs__log__resource\"></span> meeting on the #{space} space"
          expect(subject).to include action_string
        end
      end

      context "when invite doesn't exist anymore" do
        before do
          invite.destroy
          action_log.reload
        end

        it "renders the attendee name as ????" do
          expect(subject).to include "invited ???? to join"
        end
      end
    end
  end
end
