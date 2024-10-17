# frozen_string_literal: true

require "spec_helper"

describe "User manages user group", type: :system do
  shared_examples "user content submitted to spam analysis" do
    let(:queue_size) { 1 }
    let(:compared_field) { :about }
    let(:compared_against) { about }
    let(:resource) { Decidim::UserBaseEntity }
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
        expect { command.call }.to change(Decidim::UserReport, :count).by_at_least(spam_count)
        expect(Decidim::UserReport.count).to eq(spam_count)
      end
    end
  end

  let(:data) do
    {
      "group" => {
        name: "User group name",
        nickname: "nickname",
        email: "user@myrealdomain.org",
        phone: "Y1fERVzL2F",
        document_number: "123456780X",
        about:
      }
    }
  end
  let(:organization) { create(:organization) }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai::SpamDetection.reporting_user_email, organization:) }
  let(:user) { create(:user, :confirmed, organization:) }

  let(:form) do
    Decidim::UserGroupForm.from_params(**data).with_context(current_organization: organization, current_user: user)
  end

  before do
    Decidim::Ai::SpamDetection.user_registry.clear
    Decidim::Ai::SpamDetection.user_registry.register_analyzer(name: :bayes,
                                                               strategy: Decidim::Ai::SpamDetection::Strategy::Bayes,
                                                               options: { adapter: :memory, params: {} })

    Decidim::Ai::SpamDetection.user_classifier.train :ham, "I am a passionate Decidim Maintainer. It is nice to be here."
    Decidim::Ai::SpamDetection.user_classifier.train :ham, "Yet I do not have an idea about what I am doing here."
    Decidim::Ai::SpamDetection.user_classifier.train :ham, "Maybe You would understand better, and you would not get blocked as i did."
    Decidim::Ai::SpamDetection.user_classifier.train :ham, "Just kidding, I needed some Ham to make an omelette."

    Decidim::Ai::SpamDetection.user_classifier.train :spam, "You are the lucky winner! Claim your holiday prize."
  end

  shared_examples "test submitted data" do
    context "when spam content is added" do
      let(:about) { "Claim your prize today so you can win." }

      include_examples "user content submitted to spam analysis" do
        let(:spam_count) { 1 }
      end
    end

    context "when regular content is added" do
      let(:about) { "Very nice idea that is not going to be blocked" }

      include_examples "user content submitted to spam analysis" do
        let(:spam_count) { 0 }
      end
    end
  end

  context "when updating the account" do
    let(:user_group) { create(:user_group, organization:) }
    let(:command) { Decidim::UpdateUserGroup.new(form, user_group) }

    include_examples "test submitted data"
  end

  context "when creates the account" do
    let(:command) { Decidim::CreateUserGroup.new(form) }

    include_examples "test submitted data"
  end
end
