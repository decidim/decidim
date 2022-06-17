# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::CreateQuestion do
  subject { described_class.new(form) }

  let(:organization) { current_component.organization }
  let(:participatory_process) { current_component.participatory_space }
  let(:current_component) { election.component }
  let(:election) { create :election }
  let(:user) { create :user, :admin, :confirmed, organization: }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      max_selections: 3,
      weight: 10,
      random_answers_order: true,
      min_selections: 1,
      current_user: user,
      current_component:,
      current_organization: organization,
      election:
    )
  end
  let(:invalid) { false }

  let(:question) { Decidim::Elections::Question.last }

  it "creates the question" do
    expect { subject.call }.to change { Decidim::Elections::Question.count }.by(1)
  end

  it "stores the given data" do
    subject.call
    expect(translated(question.title)).to eq "title"
    expect(question.max_selections).to eq(3)
    expect(question.weight).to eq(10)
    expect(question.random_answers_order).to be_truthy
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:create!)
      .with(
        Decidim::Elections::Question,
        user,
        hash_including(:title, :max_selections, :weight, :random_answers_order),
        visibility: "all"
      )
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "create"
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the election has started" do
    let(:election) { create :election, :started }

    it "is not valid" do
      expect { subject.call }.to broadcast(:election_started)
    end
  end
end
