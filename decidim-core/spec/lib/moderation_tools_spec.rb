# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ModerationTools do
    subject { described_class.new(resource, current_user) }

    let(:resource) { create(:dummy_resource) }
    let(:current_user) { create(:user, :confirmed, organization: resource.organization) }
    let(:justification) { "This is a spam" }
    let(:report_params) { { reason: "hidden_during_block", details: justification } }

    describe "#create_report!" do
      it "creates a new report for the given resource" do
        expect { subject.create_report!(report_params) }.to change(Decidim::Report, :count).by(1)
      end

      it "creates a new moderation for the given resource" do
        expect { subject.create_report!(report_params) }.to change(Decidim::Moderation, :count).by(1)
      end
    end

    describe "#moderation" do
      it "returns the moderation for the given resource" do
        expect(subject.moderation).to eq(Decidim::Moderation.find_by(reportable: resource))
      end
    end

    describe "#send_notification_to_author" do
      let!(:report) { subject.create_report!(report_params) }

      it "sends a notification to the author of the resource" do
        expect(Decidim::EventsManager).to receive(:publish).with(hash_including(
                                                                   event: "decidim.events.reports.resource_hidden",
                                                                   extra: {
                                                                     report_reasons: [report_params[:reason]],
                                                                     force_email: true
                                                                   },
                                                                   force_send: true
                                                                 ))
        subject.send_notification_to_author
      end
    end

    describe "#hide!" do
      before do
        subject.create_report!(report_params)
      end

      it "hides the resource" do
        expect(resource).not_to be_hidden
        subject.hide!
        expect(resource.reload).to be_hidden
      end

      describe "send parent hidden notification" do
        let!(:comment) { create(:comment, author: current_user, commentable: resource) }
        let(:current_user) { create(:user, :admin, :confirmed, organization: resource.organization) }

        it "sends a notification to the author of the resource" do
          expect(Decidim::EventsManager).to receive(:publish).with(hash_including(event: "decidim.events.reports.resource_hidden"))
          expect(Decidim::EventsManager).to receive(:publish).with(hash_including(event: "decidim.events.reports.parent_hidden", resource: comment))

          perform_enqueued_jobs { subject.hide! }
        end
      end
    end

    describe "#participatory_space" do
      it "returns the participatory space of the resource" do
        expect(subject.participatory_space).to eq(resource.component.participatory_space)
      end
    end

    describe "#update_reported_content!" do
      before { subject.create_report!(report_params) }

      it "updates the reported content of the moderation" do
        expect(subject.moderation.reported_content).to be_nil
        subject.update_reported_content!
        expect(subject.moderation.reload.reported_content).to eq(resource.reported_searchable_content_text)
      end
    end

    describe "#update_report_count!" do
      before { subject.create_report!(report_params) }

      it "updates the report count of the moderation" do
        expect(subject.moderation.report_count).to eq(0)
        subject.update_report_count!
        expect(subject.moderation.reload.report_count).to eq(1)
      end
    end
  end
end
