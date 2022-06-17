# frozen_string_literal: true

shared_examples "create an initiative type scope" do
  let(:organization) { create(:organization) }
  let(:scope) { create(:scope, organization:) }
  let(:initiative_type) { create(:initiatives_type, organization:) }

  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      type_id: initiative_type.id
    )
  end

  describe "call" do
    let(:form_params) do
      {
        supports_required: 1000,
        decidim_scopes_id: scope.id
      }
    end

    let(:command) { described_class.new(form) }

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create an initiative type scope" do
        expect do
          command.call
        end.not_to change(Decidim::InitiativesTypeScope, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new initiative type scope" do
        expect do
          command.call
        end.to change { Decidim::InitiativesTypeScope.count }.by(1)
      end
    end
  end
end
