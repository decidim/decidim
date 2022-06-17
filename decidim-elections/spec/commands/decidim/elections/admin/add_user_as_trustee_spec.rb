# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::AddUserAsTrustee do
  subject { described_class.new(form, current_user) }

  let(:participatory_process) { create :participatory_process, organization: }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "elections" }
  let(:current_user) { create :user, :admin, :confirmed, organization: }
  let(:user) { create :user, :confirmed }
  let(:organization) { user.organization }
  let(:form) do
    double(
      invalid?: invalid,
      user:,
      current_user:,
      current_participatory_space: current_component.participatory_space
    )
  end
  let(:invalid) { false }

  let(:trustee) { Decidim::Elections::Trustee.last }

  context "when new trustee" do
    let(:trustee) { nil }

    it "adds the user to trustees" do
      expect { subject.call }.to change { Decidim::Elections::Trustee.count }.by(1)
    end

    it "adds the user organization to trustee" do
      subject.call
      expect(Decidim::Elections::Trustee.last.organization).to eql(user.organization)
    end

    it "sends a notification to a new trustee" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.elections.trustees.new_trustee",
          event_class: Decidim::Elections::Trustees::NotifyNewTrusteeEvent,
          resource: form.current_participatory_space,
          affected_users: [form.user]
        )
      subject.call
    end
  end

  it "adds a participatory space to trustee" do
    subject.call
    expect(trustee.trustees_participatory_spaces.count).to eq 1
  end

  it "sends an email" do
    expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
  end

  context "when user and participatory space exist" do
    let!(:trustee) do
      trustee = create(:trustee,
                       decidim_user_id: user.id)
      trustee.trustees_participatory_spaces.create(
        participatory_space: form.current_participatory_space
      )
    end

    it "broadcasts exists" do
      expect { subject.call }.to broadcast(:exists)
    end
  end
end
