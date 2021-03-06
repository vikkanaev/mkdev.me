require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test, :development)
require 'csv'
require './lib/movie_industry/types.rb'
require './lib/movie_industry/movie.rb'
Dir[File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', '**', '*.rb'))].sort.each { |f| require f }
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.warnings = true
  config.order = :random
  config.profile_examples = 10
end
