require 'test/unit'
require 'soap/rpc/standaloneServer'
require 'soap/rpc/driver'

if defined?(HTTPClient)

module SOAP

S4R_HEADERS=<<-__EOF__ 
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:xsd="http://www.w3.org/2001/XMLSchema"
xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
__EOF__
S4R_HEADERS_INDENT=<<-__EOF__ 
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
__EOF__

class TestNoIndent < Test::Unit::TestCase
  Port = 17171

  class NopServer < SOAP::RPC::StandaloneServer
    def initialize(*arg)
      super
      add_rpc_method(self, 'nop')
    end

    def nop
      SOAP::RPC::SOAPVoid.new
    end
  end

  def setup
    @server = NopServer.new(self.class.name, nil, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @t = Thread.new {
      @server.start
    }
    @endpoint = "http://localhost:#{Port}/"
    @client = SOAP::RPC::Driver.new(@endpoint)
    @client.add_rpc_method('nop')
  end

  def teardown
    @server.shutdown if @server
    if @t
      @t.kill
      @t.join
    end
    @client.reset_stream if @client
  end

  INDENT_XML =<<-__EOF__
#{S4R_HEADERS_INDENT}  <env:Body>
    <nop env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    </nop>
  </env:Body>
</env:Envelope>
__EOF__

  NO_INDENT_XML =<<-__EOF__
#{S4R_HEADERS}<env:Body>
<nop env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
</nop>
</env:Body>
</env:Envelope>
__EOF__

  def test_indent
    @client.wiredump_dev = str = ''
    @client.options["soap.envelope.no_indent"] = false
    @client.nop
    assert_equal(INDENT_XML, parse_requestxml(str) << "\n")
  end

  def test_no_indent
    @client.wiredump_dev = str = ''
    @client.options["soap.envelope.no_indent"] = true
    @client.nop
    assert_equal(NO_INDENT_XML, parse_requestxml(str) << "\n")
  end

  def parse_requestxml(str)
    str.split(/\r?\n\r?\n/)[3]
  end
end


end

end
