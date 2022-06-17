# frozen_string_literal: true

shared_examples "create an initiative" do
  let(:initiative_type) { create(:initiatives_type) }
  let(:scoped_type) { create(:initiatives_type_scope, type: initiative_type) }
  let(:author) { create(:user, organization: initiative_type.organization) }
  let(:form) do
    form_klass
      .from_params(form_params)
      .with_context(
        current_organization: initiative_type.organization,
        initiative_type:
      )
  end
  let(:uploaded_files) { [] }
  let(:current_files) { [] }

  describe "call" do
    let(:form_params) do
      {
        title: "A reasonable initiative title",
        description: "A reasonable initiative description",
        type_id: scoped_type.type.id,
        signature_type: "online",
        scope_id: scoped_type.scope.id,
        decidim_user_group_id: nil,
        add_documents: uploaded_files,
        documents: current_files
      }
    end

    let(:command) { described_class.new(form, author) }

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create an initiative" do
        expect do
          command.call
        end.not_to change(Decidim::Initiative, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new initiative" do
        expect do
          command.call
        end.to change { Decidim::Initiative.count }.by(1)
      end

      context "when attachment is present" do
        let(:uploaded_files) do
          [
            upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"))
          ]
        end

        it "creates an attachment for the proposal" do
          expect { command.call }.to change(Decidim::Attachment, :count).by(1)
          last_initiative = Decidim::Initiative.last
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(last_initiative)
        end

        context "when attachment is left blank" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end
        end
      end

      context "when has multiple attachments" do
        let(:uploaded_files) do
          [
            upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")),
            upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"))
          ]
        end

        it "creates multiple attachments for the initiative" do
          expect { command.call }.to change(Decidim::Attachment, :count).by(2)
        end
      end

      it "sets the author" do
        command.call
        initiative = Decidim::Initiative.last

        expect(initiative.author).to eq(author)
      end

      it "Default state is created" do
        command.call
        initiative = Decidim::Initiative.last

        expect(initiative).to be_created
      end

      it "Title and description are stored with its locale" do
        command.call
        initiative = Decidim::Initiative.last

        expect(initiative.title.keys).not_to be_empty
        expect(initiative.description.keys).not_to be_empty
      end

      it "Voting interval is not set yet" do
        command.call
        initiative = Decidim::Initiative.last

        expect(initiative).not_to have_signature_interval_defined
      end

      it "adds the author as follower" do
        command.call do
          on(:ok) do |assembly|
            expect(author.follows?(assembly)).to be_true
          end
        end
      end

      it "adds the author as committee member in accepted state" do
        command.call
        initiative = Decidim::Initiative.last

        expect(initiative.committee_members.accepted.where(user: author)).to exist
      end

      context "when the initiative type does not enable custom signature end date" do
        it "does not set the signature end date" do
          command.call
          initiative = Decidim::Initiative.last

          expect(initiative.signature_end_date).to be_nil
        end
      end

      context "when the initiative type enables custom signature end date" do
        let(:initiative_type) { create(:initiatives_type, :custom_signature_end_date_enabled) }

        let(:form_params) do
          {
            title: "A reasonable initiative title",
            description: "A reasonable initiative description",
            type_id: scoped_type.type.id,
            signature_type: "online",
            scope_id: scoped_type.scope.id,
            decidim_user_group_id: nil,
            signature_end_date: Date.tomorrow
          }
        end

        it "sets the signature end date" do
          command.call
          initiative = Decidim::Initiative.last

          expect(initiative.signature_end_date).to eq(Date.tomorrow)
        end
      end

      context "when the initiative type enables area" do
        let(:initiative_type) { create(:initiatives_type, :area_enabled) }
        let(:area) { create(:area, organization: initiative_type.organization) }

        let(:form_params) do
          {
            title: "A reasonable initiative title",
            description: "A reasonable initiative description",
            type_id: scoped_type.type.id,
            signature_type: "online",
            scope_id: scoped_type.scope.id,
            decidim_user_group_id: nil,
            area_id: area.id
          }
        end

        it "sets the area" do
          command.call
          initiative = Decidim::Initiative.last

          expect(initiative.decidim_area_id).to eq(area.id)
        end
      end
    end
  end
end
