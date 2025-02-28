#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'net/http'
require 'json'

# Fetch latest stable Ruby versions
def fetch_ruby_versions
  uri = URI('https://raw.githubusercontent.com/ruby/www.ruby-lang.org/master/_data/releases.yml')
  response = Net::HTTP.get(uri)
  YAML.safe_load(response)
    .map { |release| release['version'] }
    .select { |v| v =~ /^\d+\.\d+\.\d+$/ } # Only stable versions, not previews
    .map { |v| v.split('.')[0..1].join('.') } # Major.Minor format
    .uniq
    .sort_by { |v| v.split('.').map(&:to_i) }
end

# Update GitHub Actions workflow
def update_github_actions(versions)
  workflow_file = '.github/workflows/ci.yml'
  return unless File.exist?(workflow_file)

  workflow = YAML.safe_load(File.read(workflow_file))

  # Get current Ruby versions
  current_versions = workflow['jobs']['test']['strategy']['matrix']['ruby']
    .reject { |v| v == 'head' }
    .map(&:to_s)

  # Add new versions
  new_versions = versions - current_versions
  unless new_versions.empty?
    all_versions = current_versions + new_versions
    all_versions = all_versions.sort_by { |v| v.split('.').map(&:to_i) }
    all_versions << 'head'

    workflow['jobs']['test']['strategy']['matrix']['ruby'] = all_versions

    File.write(workflow_file, YAML.dump(workflow))
    puts "Updated GitHub Actions with new Ruby versions: #{new_versions.join(', ')}"
  end
end

# Update Travis CI configuration
def update_travis(versions)
  travis_file = '.travis.yml'
  return unless File.exist?(travis_file)

  travis = YAML.safe_load(File.read(travis_file))

  # Get current Ruby versions
  current_versions = travis['rvm']
    .reject { |v| v == 'ruby-head' }
    .map(&:to_s)

  # Add new versions
  new_versions = versions - current_versions
  unless new_versions.empty?
    all_versions = current_versions + new_versions
    all_versions = all_versions.sort_by { |v| v.split('.').map(&:to_i) }
    all_versions << 'ruby-head'

    travis['rvm'] = all_versions

    File.write(travis_file, YAML.dump(travis))
    puts "Updated Travis CI with new Ruby versions: #{new_versions.join(', ')}"
  end
end

puts "Checking for new Ruby versions..."
latest_versions = fetch_ruby_versions
update_github_actions(latest_versions)
update_travis(latest_versions)
puts "Done!"
