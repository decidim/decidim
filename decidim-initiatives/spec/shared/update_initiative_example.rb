# frozen_string_literal: true

shared_examples "update an initiative" do
  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, organization: organization) }

  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_component: nil,
      initiative: initiative
    )
  end

  let(:signature_end_date) { Date.current + 130.days }
  let(:form_params) do
    {
      title: { en: "A reasonable initiative title" },
      description: { en: "A reasonable initiative description" },
      signature_start_date: Date.current + 10.days,
      signature_end_date: signature_end_date,
      signature_type: "any",
      type_id: initiative.type.id,
      decidim_scope_id: initiative.scope.id,
      answer: { en: "Measured answer" },
      answer_url: "http://decidim.org",
      hashtag: "update_initiative_example",
      offline_votes: 1
    }
  end
  let(:current_user) { initiative.author }

  let(:command) { described_class.new(initiative, form, current_user) }

  describe "call" do
    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't updates the initiative" do
        command.call

        form_params.each do |key, value|
          expect(initiative[key]).not_to eq(value)
        end
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the initiative" do
        command.call
        initiative.reload

        expect(initiative.title["en"]).to eq(form_params[:title][:en])
        expect(initiative.description["en"]).to eq(form_params[:description][:en])
        expect(initiative.answer["en"]).to eq(form_params[:answer][:en])
        expect(initiative.type.id).to eq(form_params[:type_id])
        expect(initiative.signature_type).to eq(form_params[:signature_type])
        expect(initiative.answer_url).to eq(form_params[:answer_url])
        expect(initiative.hashtag).to eq(form_params[:hashtag])
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(initiative, initiative.author, kind_of(Hash))
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "voting interval remains unchanged" do
        command.call
        initiative.reload

        [:signature_start_date, :signature_end_date].each do |key|
          expect(initiative[key]).not_to eq(form_params[key])
        end
      end

      it "offline votes remain unchanged" do
        command.call
        initiative.reload
        expect(initiative.offline_votes).not_to eq(form_params[:offline_votes])
      end

      context "when administrator user" do
        let(:administrator) { create(:user, :admin, organization: organization) }

        let(:command) do
          described_class.new(initiative, form, administrator)
        end

        it "voting interval gets updated" do
          command.call
          initiative.reload

          [:signature_start_te, :signature_end_date].each do |key|
            expect(initiative[key]).to eq(form_params[key])
          end
        end

        it "offline votes gets updated" do
          command.call
          initiative.reload
          expect(initiative.offline_votes).to eq(form_params[:offline_votes])
        end
      end
    end
  end
end
