# frozen_string_literal: true

namespace :decidim do
  namespace :budgets do
    namespace :export do
      desc "Export voting results to Pabulib format"
      task :budget_pabulib, [:budget_id, :output_path] => :environment do |_, args|
        if args.budget_id.blank?
          puts "Please define the budget ID to export as the first argument."
          next
        end
        if args.output_path.blank?
          puts "Please define the output path as the second argument (e.g. tmp/budget-results-#{args.budget_id}.pb)."
          next
        end
        if File.exist?(args.output_path)
          print "File already exists at the defined output path. Do you want to override it? [y/N] "
          answer = $stdin.gets.strip
          unless %w(y Y yes).include?(answer)
            puts "Export cancelled."
            next
          end
        end

        budget = Decidim::Budgets::Budget.find_by(id: args[:budget_id])
        unless budget
          puts "Invalid budget ID: #{args[:budget_id]}"
          next
        end

        organization = budget.organization
        preferred_locale = ENV.fetch("DECIDIM_LOCALE", "")
        translated_attribute = ->(value) { value[preferred_locale] || value[organization.default_locale] || value.values.first }

        component = budget.component
        config = {
          description: "#{translated_attribute.call(organization.name)} - #{translated_attribute.call(component.name)} - #{translated_attribute.call(budget.title)}",
          unit: translated_attribute.call(budget.title),
          instance: budget.created_at.strftime("%Y"),
          min_length: 1,
          max_length: budget.projects.count,
          vote_type: "approval"
        }
        args.extras.each do |configdef|
          key, value = configdef.split("=")
          config[key.to_sym] = value
        end

        form = Decidim::Budgets::Admin::PabulibExportForm.from_params(config)
        exporter = Decidim::Budgets::Pabulib::Exporter.new(form)
        File.open(args.output_path, "w") { |file| exporter.export(budget, file) }

        puts %(Exported budget "#{translated_attribute.call(budget.title)}" (ID: #{budget.id}) to: #{args.output_path})
      end
    end
  end
end
