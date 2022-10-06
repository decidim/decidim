# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Elections::AdminLog::TrusteePresenter, type: :helper do
    subject { described_class.new(action_log, helper) }

    let(:resource) { create(:trustee) }
    let(:action_log) do
      create(
        :action_log,
        action:,
        resource:
      )
    end

    before do
      helper.extend(Decidim::ApplicationHelper)
      helper.extend(Decidim::TranslationsHelper)
    end

    describe "#present" do
      context "when the trustee is created" do
        let(:action) { :create }

        it "shows that the trustee has been created" do
          expect(subject.present).to include(resource.user.nickname)
          expect(subject.present).to include("Trustee")
        end
      end
    end
  end
end
