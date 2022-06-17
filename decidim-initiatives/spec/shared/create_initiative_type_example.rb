# frozen_string_literal: true

shared_examples "create an initiative type" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }

  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_component: nil
    )
  end

  describe "call" do
    let(:form_params) do
      {
        title: Decidim::Faker::Localized.sentence(word_count: 5),
        description: Decidim::Faker::Localized.sentence(word_count: 25),
        signature_type: "online",
        attachments_enabled: true,
        undo_online_signatures_enabled: true,
        custom_signature_end_date_enabled: true,
        area_enabled: true,
        comments_enabled: true,
        promoting_committee_enabled: true,
        minimum_committee_members: 7,
        banner_image: Decidim::Dev.test_file("city2.jpeg", "image/jpeg"),
        collect_user_extra_fields: false,
        extra_fields_legal_information: Decidim::Faker::Localized.sentence(word_count: 25),
        child_scope_threshold_enabled: false,
        only_global_scope_enabled: false
      }
    end

    let(:command) { described_class.new(form, user) }

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create an initiative type" do
        expect do
          command.call
        end.not_to change(Decidim::InitiativesType, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new initiative type" do
        expect do
          command.call
        end.to change { Decidim::InitiativesType.count }.by(1)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::InitiativesType, user, {})
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("create")
        expect(action_log.version).to be_present
      end
    end
  end
end
