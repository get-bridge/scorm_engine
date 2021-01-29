require "bundler/setup"
require "dotenv"
require "pry"
require "scorm_engine"

# Ensure we're picking up only the test scorm settings
Dotenv.load(".env.test.local",
            ".env.test",
            ".env.local",
            ".env")

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
    expectations.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  # Tag all groups and examples to use VCR
  config.define_derived_metadata do |metadata|
    metadata[:vcr] = true
  end
end

# Require every spec support file
Dir[File.join(File.dirname(__FILE__), "support", "**/*.rb")].sort.each do |file|
  require file
end
