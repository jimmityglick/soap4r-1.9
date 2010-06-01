require 'test/unit'
require 'soap/processor'


module SOAP


class TestGenerator < Test::Unit::TestCase
  # based on #417, reported by Kou.
  def test_encode
    str = "\343\201\217<"
    g = SOAP::Generator.new
    g.generate(SOAPElement.new('foo'))
    assert_equal("&lt;", g.encode_string(str)[-4, 4])
    #
    begin
#      $KCODE = 'EUC-JP'
      assert_equal("&lt;", g.encode_string(str)[-4, 4])
    ensure
 #     $KCODE = "UTF-8"
    end
  end
end


end
