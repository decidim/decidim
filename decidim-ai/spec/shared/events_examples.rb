# frozen_string_literal: true

shared_examples "content submitted to spam analysis" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai::SpamDetection.reporting_user_email, organization:) }
  let(:component) { create(:component, participatory_space:, manifest_name:) }
  let!(:author) { create(:user, :confirmed, organization:) }
  let(:queue_size) { 1 }

  before do
    Decidim::Ai::SpamDetection.resource_registry.clear
    Decidim::Ai::SpamDetection.resource_registry.register_analyzer(name: :bayes,
                                                                   strategy: Decidim::Ai::SpamDetection::Strategy::Bayes,
                                                                   options: { adapter: :memory, params: {} })

    Decidim::Ai::SpamDetection.resource_classifier.train :ham, "I am a passionate Decidim Maintainer. It is nice to be here."
    Decidim::Ai::SpamDetection.resource_classifier.train :ham, "Yet I do not have an idea about what I am doing here."
    Decidim::Ai::SpamDetection.resource_classifier.train :ham, "Maybe You would understand better, and you would not get blocked as i did."
    Decidim::Ai::SpamDetection.resource_classifier.train :ham, "Just kidding, I needed some Ham to make an omelette."

    Decidim::Ai::SpamDetection.resource_classifier.train :spam, "You are the lucky winner! Claim your holiday prize."
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

  it "hides the resource" do
    allow(Decidim::Ai::SpamDetection).to receive(:hide_reported_resources).and_return(true)
    perform_enqueued_jobs do
      expect { command.call }.to change(Decidim::Report, :count).by(spam_count)
      expect(Decidim::Report.count).to eq(spam_count)
      # We are reusing the spec for Valid and invalid content. We are just checking that the resource is hidden if the
      # resource is spam
      expect(resource.last.hidden?).to eq(spam_count == 1)
    end
  end
end

shared_examples "initiatives spam analysis" do
  context "when spam content is added" do
    let(:description) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 1 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Initiative }
      let(:component) { nil }
      let(:participatory_space) { initiative }
    end
  end

  context "when regular content is added" do
    let(:description) { "Very nice idea that is not going to be blocked by engine" }
    let(:title) { "This is the debate title" }

    include_examples "content submitted to spam analysis" do
      let(:spam_count) { 0 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Initiative }
      let(:component) { nil }
      let(:participatory_space) { initiative }
    end
  end
end

shared_examples "debates spam analysis" do
  let(:manifest_name) { "debates" }
  let(:taxonomizations) do
    2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
  end

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

  context "when regular content is added" do
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

  context "when regular content is added" do
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
  let(:taxonomizations) do
    2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
  end

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

  context "when regular content is added" do
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

  context "when regular content is added" do
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

  context "when regular content is added" do
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
