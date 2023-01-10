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
      User.create_or_promote_to_administrateur(admin_email, admin_password)
      rake_puts "Admin #{admin_email} created."
    end
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
