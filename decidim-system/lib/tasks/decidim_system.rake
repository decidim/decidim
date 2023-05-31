# frozen_string_literal: true

namespace :decidim_system do
  desc "Create a new system admin"
  task create_admin: :environment do
    puts "Please, provide the following attributes to create a new system admin#{" (currently there are existing system admins)" if Decidim::System::Admin.exists?}:"
    email = prompt("email", hidden: false)
    password = prompt("Password")
    password_confirmation = prompt("Password confirmation")

    admin = Decidim::System::Admin.new(email:, password:, password_confirmation:)

    if admin.valid?
      admin.save!
      puts("System admin created successfully")
    else
      puts("Some errors prevented creation of admin:")
      admin.errors.full_messages.uniq.each do |message|
        puts "  * #{message}"
      end
    end
  end
end

def prompt(attribute, hidden: true)
  print("#{attribute}: ")
  input = if hidden
            $stdin.noecho(&:gets).chomp
          else
            $stdin.gets.chomp
          end
  print("\n") if hidden
  input
end
