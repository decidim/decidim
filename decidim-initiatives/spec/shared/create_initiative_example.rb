# frozen_string_literal: true

shared_examples "create an initiative" do
  let(:scoped_type) { create(:initiatives_type_scope) }
  let(:author) { create(:user, organization: scoped_type.type.organization) }
  let(:form) { form_klass.from_params(form_params).with_context(current_organization: scoped_type.type.organization) }

  describe "call" do
    let(:form_params) do
      {
        title: "A reasonable initiative title",
        description: "A reasonable initiative description",
        type_id: scoped_type.type.id,
        signature_type: "online",
        scope_id: scoped_type.scope.id,
        decidim_user_group_id: nil
      }
    end

    let(:command) { described_class.new(form, author) }

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
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
    end
  end
end
