# frozen_string_literal: true

class MigrateUserRolesToParticipatoryProcessRoles < ActiveRecord::Migration[5.1]
  def up
    participatory_processes = Decidim::ParticipatoryProcess.includes(:organization).all
    Decidim::User.find_each do |user|
      next if user.roles.include? "admin"
      processes = participatory_processes.select { |process| process.organization == user.organization }
      processes.each do |process|
        user.roles.each do |role|
          Decidim::ParticipatoryProcessUserRole.find_or_create_by(user: user, participatory_process: process, role: role)
        end
      end
    end
    remove_column :decidim_users, :roles
  end
end
