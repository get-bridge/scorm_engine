RSpec.describe ScormEngine::Utils do
  describe ".sanitized_text" do
    it "removes unescaped HTML" do
      expect(described_class.sanitized_text("<b class='world'>Hello</b>")).to eq "Hello"
    end

    it "strips and squeezes all white space" do
      expect(described_class.sanitized_text(" a  b\n\r\t c ")).to eq "a b c"
    end

    pending "encodes string to utf8"
    pending "replaces invalid utf8"
    pending "replaces undefined utf8"
  end
end
