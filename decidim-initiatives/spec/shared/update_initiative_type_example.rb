# frozen_string_literal: true

shared_examples "update an initiative type" do
  let(:initiative_type) { create(:initiatives_type, :online_signature_enabled) }

  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: initiative_type.organization,
      current_component: nil
    )
  end

  describe "call" do
    let(:form_params) do
      {
        title: Decidim::Faker::Localized.sentence(5),
        description: Decidim::Faker::Localized.sentence(25),
        online_signature_enabled: false,
        banner_image: Decidim::Dev.test_file("city2.jpeg", "image/jpeg")
      }
    end

    let(:command) { described_class.new(initiative_type, form) }

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update an initiative type" do
        command.call
        expect(initiative_type.title).not_to eq(form_params[:title])
        expect(initiative_type.description).not_to eq(form_params[:description])
        expect(initiative_type.online_signature_enabled).not_to eq(form_params[:online_signature_enabled])
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the initiative type" do
        command.call

        expect(initiative_type.title).to eq(form_params[:title])
        expect(initiative_type.description).to eq(form_params[:description])
        expect(initiative_type.online_signature_enabled).to eq(form_params[:online_signature_enabled])
      end
    end
  end
end
