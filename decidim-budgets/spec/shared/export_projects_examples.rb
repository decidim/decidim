# frozen_string_literal: true

shared_examples "export projects" do
  let!(:projects) { create_list(:project, 5, budget:) }
  let(:export_type) { "Export" }

  it_behaves_like "export as CSV"
  it_behaves_like "export as JSON"
  it_behaves_like "export as Pabulib"

  context "with query" do
    before do
      fill_in "q[title_cont]", with: translated(projects.last.title)
      find("button[aria-label='Search']").click
    end

    let(:export_type) { "Export selection" }

    it_behaves_like "export as CSV"
    it_behaves_like "export as JSON"
  end
end

shared_examples "export as CSV" do
  it "exports a CSV" do
    expect(Decidim::PrivateExport.count).to eq(0)

    click_on export_type
    perform_enqueued_jobs do
      click_on "Projects as CSV"
      sleep 1
    end

    expect(page).to have_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "projects" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("projects")
  end
end

shared_examples "export as JSON" do
  it "exports a JSON" do
    expect(Decidim::PrivateExport.count).to eq(0)

    click_on export_type
    perform_enqueued_jobs do
      click_on "Projects as JSON"
      sleep 1
    end

    expect(page).to have_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "projects" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("projects")
  end
end

shared_examples "export as Pabulib" do
  shared_examples "correct Pabulib export data" do
    it "exports the results", download: true do
      fill_in :pabulib_export_country, with: "Finland"

      within ".item__edit-sticky" do
        click_on "Export"
      end

      wait_for_download
      expect(downloads.count).to eq(1)

      expect(download_content).to eq(
        <<~OUT
          META
          key;value
          #{CSV.generate_line(["description", find("input#pabulib_export_description").value], col_sep: ";").strip}
          country;#{find("input#pabulib_export_country").value}
          #{CSV.generate_line(["unit", find("input#pabulib_export_unit").value], col_sep: ";").strip}
          instance;#{find("input#pabulib_export_instance").value}
          num_projects;#{budget.projects.count}
          num_votes;0
          budget;#{budget.total_budget}
          rule;greedy
          #{vote_type_data}
          PROJECTS
          project_id;name;cost;votes;selected
          #{budget.projects.order(:id).map { |pr| CSV.generate_line([pr.id, pr.title["en"], pr.budget_amount, 0, pr.selected? ? 1 : 0], col_sep: ";") }.join.strip}
        OUT
      )
    end
  end

  before do
    click_on export_type
    click_on "Voting results as Pabulib"
    expect(page).to have_content("Export voting results for #{translated_attribute(budget.title)} to Pabulib format")
  end

  it "sets the initial general details correctly" do
    expect(find("input#pabulib_export_description").value).to eq("#{translated_attribute(organization.name)} - #{translated_attribute(component.name)} - #{translated_attribute(budget.title)}")
    expect(find("input#pabulib_export_unit").value).to eq(translated_attribute(budget.title))
    expect(find("select#pabulib_export_vote_type").value).to eq("approval")
    expect(find("input#pabulib_export_instance").value).to eq(budget.created_at.strftime("%Y"))
  end

  context "with approval vote type" do
    let(:download_content) { File.read(downloads.first) }

    before { select "approval", from: :pabulib_export_vote_type }

    it_behaves_like "correct Pabulib export data" do
      let(:vote_type_data) do
        <<~DATA.strip
          vote_type;approval
          min_length;#{find("input#pabulib_export_min_length").value}
          max_length;#{find("input#pabulib_export_max_length").value}
        DATA
      end
    end

    it "shows the correct fields" do
      expect(page).to have_field(:pabulib_export_min_length, visible: :visible)
      expect(page).to have_field(:pabulib_export_max_length, visible: :visible)
      expect(page).to have_field(:pabulib_export_min_sum_cost, visible: :visible)
      expect(page).to have_field(:pabulib_export_max_sum_cost, visible: :visible)

      expect(page).to have_select(:pabulib_export_scoring_fn, visible: :hidden)
      expect(page).to have_field(:pabulib_export_min_sum_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_max_sum_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_min_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_max_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_default_score, visible: :hidden)
    end

    it "sets the initial values correctly" do
      expect(find("input#pabulib_export_min_length").value).to eq("1")
      expect(find("input#pabulib_export_max_length").value).to eq(budget.projects.count.to_s)
      expect(find("input#pabulib_export_min_sum_cost").value).to be_blank
      expect(find("input#pabulib_export_max_sum_cost").value).to be_blank
    end
  end

  context "with ordinal vote type" do
    before { select "ordinal", from: :pabulib_export_vote_type }

    it_behaves_like "correct Pabulib export data" do
      let(:vote_type_data) do
        <<~DATA.strip
          vote_type;ordinal
          min_length;#{find("input#pabulib_export_min_length").value}
          max_length;#{find("input#pabulib_export_max_length").value}
          scoring_fn;#{find("select#pabulib_export_scoring_fn").value}
        DATA
      end
    end

    it "shows the correct fields" do
      expect(page).to have_field(:pabulib_export_min_length, visible: :visible)
      expect(page).to have_field(:pabulib_export_max_length, visible: :visible)
      expect(page).to have_select(:pabulib_export_scoring_fn, visible: :visible)

      expect(page).to have_field(:pabulib_export_min_sum_cost, visible: :hidden)
      expect(page).to have_field(:pabulib_export_max_sum_cost, visible: :hidden)
      expect(page).to have_field(:pabulib_export_min_sum_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_max_sum_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_min_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_max_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_default_score, visible: :hidden)
    end

    it "sets the initial values correctly" do
      expect(find("input#pabulib_export_min_length").value).to eq("1")
      expect(find("input#pabulib_export_max_length").value).to eq(budget.projects.count.to_s)
      expect(find("select#pabulib_export_scoring_fn").value).to eq("Borda")
    end
  end

  context "with cumulative vote type" do
    before { select "cumulative", from: :pabulib_export_vote_type }

    it_behaves_like "correct Pabulib export data" do
      let(:vote_type_data) do
        <<~DATA.strip
          vote_type;cumulative
          min_length;#{find("input#pabulib_export_min_length").value}
          max_length;#{find("input#pabulib_export_max_length").value}
        DATA
      end
    end

    it "shows the correct fields" do
      expect(page).to have_field(:pabulib_export_min_length, visible: :visible)
      expect(page).to have_field(:pabulib_export_max_length, visible: :visible)
      expect(page).to have_field(:pabulib_export_min_sum_points, visible: :visible)
      expect(page).to have_field(:pabulib_export_max_sum_points, visible: :visible)
      expect(page).to have_field(:pabulib_export_min_points, visible: :visible)
      expect(page).to have_field(:pabulib_export_max_points, visible: :visible)

      expect(page).to have_field(:pabulib_export_min_sum_cost, visible: :hidden)
      expect(page).to have_field(:pabulib_export_max_sum_cost, visible: :hidden)
      expect(page).to have_select(:pabulib_export_scoring_fn, visible: :hidden)
      expect(page).to have_field(:pabulib_export_default_score, visible: :hidden)
    end

    it "sets the initial values correctly" do
      expect(find("input#pabulib_export_min_length").value).to eq("1")
      expect(find("input#pabulib_export_max_length").value).to eq(budget.projects.count.to_s)
      expect(find("input#pabulib_export_min_sum_points").value).to be_blank
      expect(find("input#pabulib_export_max_sum_points").value).to be_blank
      expect(find("input#pabulib_export_min_points").value).to be_blank
      expect(find("input#pabulib_export_max_points").value).to be_blank
    end
  end

  context "with scoring vote type" do
    before { select "scoring", from: :pabulib_export_vote_type }

    it_behaves_like "correct Pabulib export data" do
      let(:vote_type_data) do
        <<~DATA.strip
          vote_type;scoring
          min_length;#{find("input#pabulib_export_min_length").value}
          max_length;#{find("input#pabulib_export_max_length").value}
        DATA
      end
    end

    it "shows the correct fields" do
      expect(page).to have_field(:pabulib_export_min_length, visible: :visible)
      expect(page).to have_field(:pabulib_export_max_length, visible: :visible)
      expect(page).to have_field(:pabulib_export_min_points, visible: :visible)
      expect(page).to have_field(:pabulib_export_max_points, visible: :visible)
      expect(page).to have_field(:pabulib_export_default_score, visible: :visible)

      expect(page).to have_field(:pabulib_export_min_sum_cost, visible: :hidden)
      expect(page).to have_field(:pabulib_export_max_sum_cost, visible: :hidden)
      expect(page).to have_select(:pabulib_export_scoring_fn, visible: :hidden)
      expect(page).to have_field(:pabulib_export_min_sum_points, visible: :hidden)
      expect(page).to have_field(:pabulib_export_max_sum_points, visible: :hidden)
    end

    it "sets the initial values correctly" do
      expect(find("input#pabulib_export_min_length").value).to eq("1")
      expect(find("input#pabulib_export_max_length").value).to eq(budget.projects.count.to_s)
      expect(find("input#pabulib_export_min_points").value).to be_blank
      expect(find("input#pabulib_export_max_points").value).to be_blank
      expect(find("input#pabulib_export_default_score").value).to be_blank
    end
  end
end
