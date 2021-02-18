# frozen_string_literal: true

namespace :bootstrap do
  desc "Create admin"
  task admin: :environment do
    enabled        = ENV.fetch("BOOTSTRAP_ADMIN_ENABLED", "0").to_i == 1
    admin_email    = ENV["BOOTSTRAP_ADMIN_EMAIL"]
    admin_password = ENV["BOOTSTRAP_ADMIN_PASSWORD"]

    if !enabled || admin_email.blank? || admin_password.blank?
      rake_puts "Boostrap admin mode disabled."
    else
      rake_puts "Boostrap admin mode enabled…"

      User.transaction do
        user = User.create!(
          email: admin_email,
          password: admin_password,
          confirmed_at: Time.zone.now
        )
        user.create_instructeur!
        user.create_administrateur!
      end

      rake_puts "Admin #{admin_email} created."
    end
  rescue ActiveRecord::RecordInvalid => e
    rake_puts e.message
    exit 1
  end

  desc "Create a new super-admin account"
  task superadmin: :environment do
    enabled = ENV.fetch("BOOTSTRAP_SUPERADMIN_ENABLED", "0").to_i == 1
    email   = ENV["BOOTSTRAP_SUPERADMIN_EMAIL"]

    if !enabled || email.blank?
      rake_puts "Boostrap superadmin mode disabled."
    else
      rake_puts "Boostrap superadmin mode enabled…"
      Rake::Task["superadmin:create"].invoke(email)
    end
  end

  desc "Create admin & super-admin accounts"
  task :all => [:admin, :superadmin]
end
