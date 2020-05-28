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
  let(:attachment_params) { nil }
  let(:form_params) do
    {
      title: { en: "A reasonable initiative title" },
      description: { en: "A reasonable initiative description" },
      signature_start_date: Date.current + 10.days,
      signature_end_date: signature_end_date,
      signature_type: "any",
      type_id: initiative.type.id,
      decidim_scope_id: initiative.scope.id,
      hashtag: "update_initiative_example",
      offline_votes: 1,
      attachment: attachment_params
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
        expect do
          command.call
        end.not_to change(initiative, :title)
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
        expect(initiative.type.id).to eq(form_params[:type_id])
        expect(initiative.hashtag).to eq(form_params[:hashtag])
      end

      context "when attachment is present", processing_uploads_for: Decidim::AttachmentUploader do
        let(:attachment_params) do
          {
            title: "My attachment",
            file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
          }
        end

        it "creates an atachment for the proposal" do
          expect { command.call }.to change(Decidim::Attachment, :count).by(1)
          last_initiative = Decidim::Initiative.last
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(last_initiative)
        end

        context "when attachment is left blank" do
          let(:attachment_params) do
            {
              title: ""
            }
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end
        end
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

      describe "when in created state" do
        let!(:initiative) { create(:initiative, :created, signature_type: "online") }

        before { form.signature_type = "offline" }

        it "updates signature type" do
          expect { command.call }.to change(initiative, :signature_type).from("online").to("offline")
        end
      end

      describe "when not in created state" do
        let!(:initiative) { create(:initiative, :published, signature_type: "online") }

        before { form.signature_type = "offline" }

        it "doesn't update signature type" do
          expect { command.call }.not_to change(initiative, :signature_type)
        end
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
