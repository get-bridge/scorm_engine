module ScormEngine
  module Models
    class Test < Base
      # rubocop:disable Lint/MissingSuper
      def initialize(options = {})
        @options = options
      end
      # rubocop:enable Lint/MissingSuper
    end
  end
end

RSpec.describe ScormEngine::Models::Base do
  describe "#to_hash" do
    it "returns a hash of the options" do
      options = { i: 1, s: "str", a: [1, 2, 3] }
      test = ScormEngine::Models::Test.new(options)
      expect(test.to_hash).to eq options
    end
  end
end
