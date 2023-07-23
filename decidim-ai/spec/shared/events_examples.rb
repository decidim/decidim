# frozen_string_literal: true

shared_examples "content submitted to spam analysis" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai.reporting_user_email, organization:) }
  let(:component) { create(:component, participatory_space:, manifest_name:) }
  let!(:author) { create(:user, organization:) }
  let(:queue_size) { 1 }

  before do
    Decidim::Ai.spam_detection_registry.clear
    Decidim::Ai.spam_detection_registry.register_analyzer(name: :bayes,
                                                          strategy: Decidim::Ai::SpamContent::BayesStrategy,
                                                          options: { adapter: :memory, params: {} })

    Decidim::Ai.spam_detection_instance.train :ham, "I am a passionate Decidim Maintainer. It is nice to be here."
    Decidim::Ai.spam_detection_instance.train :ham, "Yet I do not have an idea about what I am doing here."
    Decidim::Ai.spam_detection_instance.train :ham, "Maybe You would understand better, and you would not get blocked as i did."
    Decidim::Ai.spam_detection_instance.train :ham, "Just kidding, I needed some Ham to make an omelette."

    Decidim::Ai.spam_detection_instance.train :spam, "You are the lucky winner! Claim your holiday prize."
  end

  it "updates the about text" do
    expect { command.call }.to broadcast(:ok)
    field = resource.last.reload.send(compared_field)
    expect(field.is_a?(String) ? field : field[I18n.locale.to_s]).to eq(compared_against)
  end

  it "fires the event" do
    expect { command.call }.to have_enqueued_job.on_queue("spam_analysis")
                                                .exactly(queue_size).times
  end

  it "processes the event" do
    perform_enqueued_jobs do
      expect { command.call }.to change(Decidim::Report, :count).by(spam_count)
      expect(Decidim::Report.count).to eq(spam_count)
    end
  end
end

shared_examples "debates spam analysis" do
  let(:manifest_name) { "debates" }
  let(:scope) { create(:scope, organization:) }
  let(:category) { create(:category, participatory_space:) }

  context "when spam content is added" do
    let(:description) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 1 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Debates::Debate }
    end
  end

  context "when regular content content is added" do
    let(:description) { "Very nice idea that is not going to be blocked by engine" }
    let(:title) { "This is the debate title" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 0 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Debates::Debate }
    end
  end
end

shared_examples "comments spam analysis" do
  let(:manifest_name) { "dummy" }
  let(:dummy_resource) { create(:dummy_resource, component:) }
  let(:commentable) { dummy_resource }

  context "when spam content is added" do
    let(:body) { "Claim your prize today so you can win." }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 1 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Comments::Comment }
    end
  end

  context "when regular content content is added" do
    let(:body) { "Very nice idea that is not going to be blocked by engine" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 0 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Comments::Comment }
    end
  end
end

shared_examples "meetings spam analysis" do
  let(:manifest_name) { "meetings" }
  let(:scope) { create(:scope, organization:) }
  let(:category) { create(:category, participatory_space:) }

  context "when spam content is added" do
    let(:description) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 1 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Meetings::Meeting }
    end
  end

  context "when regular content content is added" do
    let(:description) { "Very nice idea that is not going to be blocked by engine" }
    let(:title) { "This is the collaborative draft title" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 0 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Meetings::Meeting }
    end
  end
end

shared_examples "proposal spam analysis" do
  let(:manifest_name) { "proposals" }
  let(:user_group) { nil }

  context "when spam content is added" do
    let(:body) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 1 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Proposals::Proposal }
    end
  end

  context "when regular content content is added" do
    let(:body) { "Very nice idea that is not going to be blocked by engine" }
    let(:title) { "This is the collaborative draft title" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 0 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Proposals::Proposal }
    end
  end
end

shared_examples "Collaborative draft spam analysis" do
  let(:user_group) { nil }

  context "when spam content is added" do
    let(:body) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled, participatory_space:) }
      let(:spam_count) { 1 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Proposals::CollaborativeDraft }
    end
  end

  context "when regular content content is added" do
    let(:body) { "Very nice idea that is not going to be blocked by engine" }
    let(:title) { "This is the collaborative draft title" }

    include_examples "content submitted to spam analysis" do
      let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled, participatory_space:) }
      let(:spam_count) { 0 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Proposals::CollaborativeDraft }
    end
  end
end
