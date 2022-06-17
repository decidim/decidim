# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::CreateAnswer do
  subject(:command) { described_class.new(form) }

  let(:organization) { component.organization }
  let(:participatory_process) { component.participatory_space }
  let(:component) { election.component }
  let(:question) { create :question, election: }
  let(:election) { create :election }
  let(:user) { create :user, :admin, :confirmed, organization: }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      weight: 10,
      proposals:,
      proposal_ids: proposals.map(&:id),
      attachment: attachment_params,
      photos:,
      add_photos: uploaded_photos,
      current_user: user,
      current_component: component,
      current_organization: organization,
      election:,
      question:
    )
  end
  let(:proposals) { [] }
  let(:photos) { [] }
  let(:uploaded_photos) { [] }
  let(:attachment_params) { nil }
  let(:invalid) { false }

  let(:answer) { Decidim::Elections::Answer.last }

  it "creates the answer" do
    expect { subject.call }.to change { Decidim::Elections::Answer.count }.by(1)
  end

  it "stores the given data" do
    subject.call
    expect(translated(answer.title)).to eq "title"
    expect(translated(answer.description)).to eq "description"
    expect(answer.weight).to eq(10)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:create!)
      .with(
        Decidim::Elections::Answer,
        user,
        hash_including(:title, :description, :weight),
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
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "with proposals" do
    let(:proposals_component) { create :component, manifest_name: :proposals, participatory_space: component.participatory_space }
    let(:proposals) { create_list :proposal, 2, component: proposals_component }

    it "creates the answer" do
      expect { subject.call }.to change { Decidim::Elections::Answer.count }.by(1)
    end

    it "stores the relations with proposals" do
      subject.call
      expect(answer.proposals).to match_array(proposals)
    end
  end

  context "with attachment" do
    it_behaves_like "admin creates resource gallery" do
      let(:resource_class) { Decidim::Elections::Answer }
      let(:attachment_params) do
        {
          title: "My attachment",
          file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
        }
      end
    end
  end
end
