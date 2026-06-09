# frozen_string_literal: true

require "spec_helper"

describe "Executing Pabulib export tasks" do
  let(:organization) { create(:organization, host: "foo.example.org") }
  let(:participatory_space) { create(:participatory_process, title: { "en" => "Process" }, organization:) }
  let(:component) { create(:budgets_component, :with_minimum_budget_projects, organization:, participatory_space:, vote_minimum_budget_projects_number: 1) }
  let(:budget) { create(:budget, component:) }
  let!(:projects) do
    [
      create(:project, budget:, budget_amount: 10_000_000),
      create(:project, budget:, budget_amount: 15_000_000),
      create(:project, budget:, budget_amount: 20_000_000)
    ]
  end
  let!(:orders) do
    [[0], [1], [2], [0, 1], [1, 2], [0, 2]].map do |items|
      create(:order, budget:).tap do |order|
        items.each do |idx|
          create(:line_item, project: projects[idx], order:)
        end

        order.reload
        order.update!(checked_out_at: Time.current)
      end
    end
  end

  describe "rake decidim:budgets:export:budget_pabulib", type: :task do
    let(:task) { Rake::Task["decidim:budgets:export:budget_pabulib"] }
    let(:output_path) { Rails.root.join("tmp/budgets/#{organization.host}_#{budget.id}_pabulib.pb") }
    let(:output) { File.read(output_path) }
    let(:calculate_votes) do
      lambda do |project|
        Decidim::Budgets::LineItem.joins(:order).where(project:).where.not(
          decidim_budgets_orders: { checked_out_at: nil }
        ).count
      end
    end

    around do |example|
      task.reenable

      FileUtils.rm_f(output_path)
      FileUtils.mkdir_p(File.dirname(output_path))

      I18n.with_locale(:en) { example.run }
    end

    it "returns the correct output" do
      task.invoke(budget.id, output_path)

      expect($stdout.string).to include(%(Exported budget "#{translated_attribute(budget.title)}" (ID: #{budget.id}) to: #{output_path}))
    end

    it "creates the export with correct details" do
      task.invoke(budget.id, output_path)

      expect(output).to eq(
        <<~OUT
          META
          key;value
          #{CSV.generate_line(["description", "#{translated_attribute(organization.name)} - #{translated_attribute(component.name)} - #{translated_attribute(budget.title)}"], col_sep: ";").strip}
          #{CSV.generate_line(["unit", translated_attribute(organization.name)], col_sep: ";").strip}
          #{CSV.generate_line(["subunit", translated_attribute(budget.title)], col_sep: ";").strip}
          instance;#{budget.created_at.strftime("%Y")}
          num_projects;#{projects.count}
          num_votes;#{orders.count}
          budget;#{budget.total_budget}
          vote_type;approval
          rule;greedy
          date_begin;#{orders.map(&:created_at).min.strftime("%d.%m.%Y")}
          date_end;#{orders.map(&:created_at).max.strftime("%d.%m.%Y")}
          min_length;1
          max_length;#{projects.count}
          PROJECTS
          project_id;cost;votes;name;selected
          #{budget.projects.order(:id).map { |pr| CSV.generate_line([pr.id, pr.budget_amount, calculate_votes.call(pr), pr.title["en"], pr.selected? ? 1 : 0], col_sep: ";") }.join.strip}
          VOTES
          voter_id;vote
          #{orders.map { |ord| "#{ord.id};#{ord.projects.order(:id).pluck(:id).join(",")}" }.join("\n")}
        OUT
      )
    end

    context "without a budget ID" do
      before { task.invoke }

      it "does not export" do
        expect(File.exist?(output_path)).to be(false)
      end

      it "returns the correct output" do
        expect($stdout.string).to include("Please define the budget ID to export as the first argument.")
      end
    end

    context "without an output path" do
      before { task.invoke(budget.id) }

      it "does not export" do
        expect(File.exist?(output_path)).to be(false)
      end

      it "returns the correct output" do
        expect($stdout.string).to include("Please define the output path as the second argument (e.g. tmp/budget-results-#{budget.id}.pb).")
      end
    end

    context "with the output file already exists" do
      let(:question_answer) { "n" }

      before do
        allow($stdin).to receive(:gets).and_return(question_answer)

        File.write(output_path, "test file")
        task.invoke(budget.id, output_path)
      end

      it "returns the correct output" do
        expect($stdout.string).to include("File already exists at the defined output path. Do you want to override it? [y/N] ")
      end

      context "when answering no" do
        it "exits with the correct message" do
          expect($stdout.string).to include("Export cancelled.")
          expect(File.read(output_path)).to eq("test file")
        end
      end

      context "when answering yes" do
        let(:question_answer) { "y" }

        it "proceeds and exports the data" do
          expect($stdout.string).not_to include("Export cancelled.")
          expect($stdout.string).to include(%(Exported budget "#{translated_attribute(budget.title)}" (ID: #{budget.id}) to: #{output_path}))
          expect(File.read(output_path)).not_to eq("test file")
        end
      end
    end

    context "with invalid budget ID" do
      before { task.invoke(budget.id + 999, output_path) }

      it "does not export" do
        expect(File.exist?(output_path)).to be(false)
      end

      it "returns the correct output" do
        expect($stdout.string).to include("Invalid budget ID: #{budget.id + 999}")
      end
    end
  end
end
