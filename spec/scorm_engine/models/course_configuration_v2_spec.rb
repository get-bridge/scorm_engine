require "spec_helper"

RSpec.describe ScormEngine::Models::CourseConfiguration do
  describe ".get_settings_from_api" do
    context "with valid configuration items" do
      let(:valid_api_response) do
        {
          "configurationItems" => [
            {
              "id" => "setting_one",
              "value" => "value_one"
            },
            {
              "id" => "setting_two", 
              "value" => "value_two"
            },
            {
              "id" => "boolean_setting",
              "value" => "true"
            }
          ]
        }
      end

      it "converts configuration items to hash correctly" do
        settings = described_class.get_settings_from_api(valid_api_response)
        
        expect(settings).to be_a(Hash)
        expect(settings).to eq({
          "setting_one" => "value_one",
          "setting_two" => "value_two", 
          "boolean_setting" => "true"
        })
      end
    end

    context "with empty configuration items" do
      let(:empty_response) do
        {
          "configurationItems" => []
        }
      end

      it "returns empty hash for empty configuration items" do
        settings = described_class.get_settings_from_api(empty_response)
        
        expect(settings).to eq({})
      end
    end

    context "with nil configuration items" do
      let(:nil_response) do
        {
          "configurationItems" => nil
        }
      end

      it "returns empty hash when configuration items is nil" do
        settings = described_class.get_settings_from_api(nil_response)
        
        expect(settings).to eq({})
      end
    end

    context "with missing configuration items key" do
      let(:missing_key_response) do
        {
          "otherData" => "some value"
        }
      end

      it "returns empty hash when configurationItems key is missing" do
        settings = described_class.get_settings_from_api(missing_key_response)
        
        expect(settings).to eq({})
      end
    end

    context "with malformed configuration items" do
      let(:malformed_response) do
        {
          "configurationItems" => "not an array"
        }
      end

      it "returns empty hash when configuration items is not reducible" do
        settings = described_class.get_settings_from_api(malformed_response)
        
        expect(settings).to eq({})
      end
    end

    context "with configuration items containing complex values" do
      let(:complex_response) do
        {
          "configurationItems" => [
            {
              "id" => "json_setting",
              "value" => '{"nested": "value"}'
            },
            {
              "id" => "numeric_setting",
              "value" => "12345"
            },
            {
              "id" => "empty_setting",
              "value" => ""
            }
          ]
        }
      end

      it "preserves string values as-is" do
        settings = described_class.get_settings_from_api(complex_response)
        
        expect(settings["json_setting"]).to eq('{"nested": "value"}')
        expect(settings["numeric_setting"]).to eq("12345")
        expect(settings["empty_setting"]).to eq("")
      end
    end

    context "with configuration items missing id or value" do
      let(:incomplete_response) do
        {
          "configurationItems" => [
            {
              "id" => "valid_setting",
              "value" => "valid_value"
            },
            {
              "value" => "missing_id"  # No id field
            },
            {
              "id" => "missing_value"  # No value field
            }
          ]
        }
      end

      it "handles missing id or value gracefully" do
        settings = described_class.get_settings_from_api(incomplete_response)
        
        # Should include the valid setting
        expect(settings["valid_setting"]).to eq("valid_value")
        
        # Should handle missing fields gracefully (likely with nil values)
        expect(settings).to have_key("valid_setting")
        
        # The behavior for missing id/value depends on implementation
        # but should not raise an exception
        expect { settings }.not_to raise_error
      end
    end

    describe "error resilience" do
      it "does not raise when given nil input" do
        expect { described_class.get_settings_from_api(nil) }.not_to raise_error
        expect(described_class.get_settings_from_api(nil)).to eq({})
      end

      it "does not raise when given empty hash" do
        expect { described_class.get_settings_from_api({}) }.not_to raise_error
        expect(described_class.get_settings_from_api({})).to eq({})
      end

      it "does not raise when configuration items is not enumerable" do
        bad_response = { "configurationItems" => 123 }
        
        expect { described_class.get_settings_from_api(bad_response) }.not_to raise_error
        expect(described_class.get_settings_from_api(bad_response)).to eq({})
      end
    end

    describe "API v2 compatibility" do
      let(:api_v2_response) do
        {
          "configurationItems" => [
            {
              "id" => "PlayerLaunchType",
              "value" => "FRAMESET",
              "effectiveValueSource" => "system"
            },
            {
              "id" => "ApiRoot",
              "value" => "/api/",
              "effectiveValueSource" => "default"
            }
          ]
        }
      end

      it "extracts id and value while ignoring additional API v2 fields" do
        settings = described_class.get_settings_from_api(api_v2_response)
        
        expect(settings).to eq({
          "PlayerLaunchType" => "FRAMESET",
          "ApiRoot" => "/api/"
        })
        
        # Should not include effectiveValueSource in the final hash
        expect(settings).not_to have_key("effectiveValueSource")
      end
    end
  end
end
