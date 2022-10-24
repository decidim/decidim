# frozen_string_literal: true

shared_examples "admin imports controller" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:component) { create(:component, participatory_space:, manifest_name: "dummy") }

  let(:default_params) do
    {
      component_id: component.id,
      name: "dummies"
    }
  end
  let(:extra_params) { {} }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user, scope: :user
  end

  describe "POST create" do
    # The file does not really matter for the dummies creator because it
    # will always create a record for each data row regardless of the data.
    let(:file) { upload_test_file(Decidim::Dev.test_file("import_proposals.csv", "text/csv")) }
    let(:params) do
      default_params.merge(extra_params).merge(file:)
    end

    it "imports dummies" do
      post(:create, params:)
      expect(response).to have_http_status(:found)
      expect(flash[:notice]).not_to be_empty

      expect(Decidim::DummyResources::DummyResource.count).to eq(3)
      Decidim::DummyResources::DummyResource.find_each do |dummy|
        expect(dummy.title).to eq("en" => "Dummy")
        expect(dummy.author).to eq(user)
        expect(dummy.component).to eq(component)
      end
    end
  end

  describe "GET example" do
    let(:params) do
      default_params.merge(extra_params).merge(format:)
    end

    context "with CSV format" do
      let(:format) { "csv" }

      it "creates a correct CSV example file" do
        get(:example, params:)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to eq(
          "attachment; filename=\"dummy-dummies-example.csv\"; filename*=UTF-8''dummy-dummies-example.csv"
        )
        expect(response.body).to eq(
          File.read(Decidim::Dev.asset("dummy-dummies-example.csv"))
        )
      end
    end

    context "with JSON format" do
      let(:format) { "json" }

      it "creates a correct JSON example file" do
        get(:example, params:)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json")
        expect(response.headers["Content-Disposition"]).to eq(
          "attachment; filename=\"dummy-dummies-example.json\"; filename*=UTF-8''dummy-dummies-example.json"
        )
        expect(response.body).to eq(
          File.read(Decidim::Dev.asset("dummy-dummies-example.json"))
        )
      end
    end

    context "with XLSX format" do
      let(:format) { "xlsx" }

      it "creates a correct XLSX example file" do
        get(:example, params:)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq(
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        )
        expect(response.headers["Content-Disposition"]).to eq(
          "attachment; filename=\"dummy-dummies-example.xlsx\"; filename*=UTF-8''dummy-dummies-example.xlsx"
        )

        # The generated XLSX can have some byte differences which is why we need
        # to read the values from both files and compare them instead.
        workbook = RubyXL::Parser.parse_buffer(response.body)
        actual = workbook.worksheets[0].map { |row| row.cells.map(&:value) }

        workbook = RubyXL::Parser.parse(Decidim::Dev.asset("dummy-dummies-example.xlsx"))
        expected = workbook.worksheets[0].map { |row| row.cells.map(&:value) }

        expect(actual).to eq(expected)
      end
    end

    context "with unknown format" do
      let(:format) { "foo" }

      it "raises ActionController::UnknownFormat" do
        expect { get(:example, params:) }.to raise_error(
          ActionController::UnknownFormat
        )
      end
    end
  end

  context "with abstract creator" do
    let(:creator) { Decidim::Admin::Import::Creator.new({ id: 1, "title/en": "My title for abstract creator" }) }
    let(:params) do
      default_params.merge(extra_params).merge(name: "abstract")
    end

    describe "POST create" do
      it "raises ActionController::RoutingError" do
        expect { post(:create, params:) }.to raise_error(
          ActionController::RoutingError
        )
      end
    end

    describe "GET example" do
      it "raises ActionController::RoutingError" do
        expect { get(:example, params:) }.to raise_error(
          ActionController::RoutingError
        )
      end
    end
  end
end
