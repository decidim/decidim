# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::DestroyProject do
    subject { described_class.new(project, current_user) }

    let(:project) { create :project }
    let!(:image) { create(:attachment, :with_image, attached_to: project) }
    let(:organization) { project.component.organization }
    let(:current_user) { create :user, :admin, :confirmed, organization: }

    context "when everything is ok" do
      it_behaves_like "admin destroys resource gallery" do
        let(:command) { described_class.new(project, current_user) }
      end

      it "destroys the project" do
        subject.call
        expect { project.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:delete, project, current_user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
