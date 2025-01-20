# frozen_string_literal: true

shared_context "with proposal and users allowed to create proposal notes" do
  let(:participatory_space) { create(:participatory_process, :with_steps) }
  let(:organization) { participatory_space.organization }
  let(:component) { create(:proposal_component, participatory_space:) }
  let(:proposal) { create(:proposal, component:) }

  let(:current_user) { create(:user, :admin, organization:) }
  let!(:another_admin) { create(:user, :admin, organization:) }

  let!(:evaluator) { create(:user, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: participatory_space) }
  let!(:evaluation_assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }

  let!(:other_evaluation_assignment) { create(:evaluation_assignment) }
  let!(:other_proposal_evaluator) { other_evaluation_assignment.evaluator }

  let!(:participatory_space_admin) { create(:user, organization:) }
  let!(:participatory_space_admin_role) { create(:participatory_process_user_role, role: :admin, user: participatory_space_admin, participatory_process: participatory_space) }

  let!(:other_participatory_space_admin) { create(:user, organization:) }
  let!(:other_participatory_space_admin_role) { create(:participatory_process_user_role, role: :admin, user: other_participatory_space_admin) }

  let!(:normal_user) { create(:user, organization:) }

  let(:form) { Decidim::Proposals::Admin::ProposalNoteForm.from_params(form_params).with_context(current_user:, current_organization: organization) }

  let(:form_params) { { body: } }
  let(:body) { "A reasonable private note" }

  let!(:proposal_note) { create(:proposal_note, proposal:, author:) }
  let(:author) { another_admin }

  def body_with_mentions(*users)
    "Hi, #{users.map { |user| "@#{user.nickname}" }.join(", ")}"
  end
end

shared_examples "a proposal note command call" do
  describe "when the form is not valid" do
    before do
      allow(form).to receive(:invalid?).and_return(true)
    end

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end

    it "does not create the proposal note" do
      expect do
        command.call
      end.not_to change(Decidim::Proposals::ProposalVote, :count)
    end
  end

  describe "when the form is valid" do
    before do
      allow(form).to receive(:invalid?).and_return(false)
    end

    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "creates the proposal notes" do
      expect do
        command.call
      end.to change(Decidim::Proposals::ProposalNote, :count).by(1)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:create!)
        .with(Decidim::Proposals::ProposalNote, current_user, hash_including(:body, :proposal, :author), resource: hash_including(:title))
        .and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end
end
