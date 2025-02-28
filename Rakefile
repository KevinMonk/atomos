# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

namespace :sorbet do
  desc 'Run Sorbet type checker'
  task :typecheck do
    sh 'bundle exec srb tc'
  end

  desc 'Initialize Sorbet RBI files'
  task :init do
    sh 'bundle exec tapioca init'
  end

  desc 'Generate RBI files for gems'
  task :generate_gem_rbis do
    sh 'bundle exec tapioca gems'
  end

  desc 'Generate RBI files for the project'
  task :generate_project_rbis do
    sh 'bundle exec tapioca dsl'
    sh 'bundle exec srb rbi hidden-definitions'
    sh 'bundle exec srb rbi todo'
  end
end

task :typecheck do
  Rake::Task['sorbet:typecheck'].invoke
end

task default: %i[spec rubocop typecheck]
