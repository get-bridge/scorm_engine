RSpec.describe ScormEngine::Models::Base do

  module ScormEngine
    module Models
      class Test < Base
        def initialize(options = {})
          @options = options
        end
      end
    end
  end

  describe "#to_hash" do
    it "returns a hash of the options" do
      options = {i: 1, s: "str", a: [1, 2, 3]}
      test = ScormEngine::Models::Test.new(options)
      expect(test.to_hash).to eq options
    end
  end
end
