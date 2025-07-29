#!/usr/bin/env ruby
# LSP Protocol Test Suite for Ruby LSP
# Based on LSP Specification 3.17

require 'json'
require 'socket'
require 'open3'

class LSPProtocolTest
  def initialize
    @request_id = 0
  end

  # Build JSON-RPC request
  def build_request(method, params = {})
    @request_id += 1
    request = {
      jsonrpc: "2.0",
      id: @request_id,
      method: method,
      params: params
    }
    
    content = JSON.generate(request)
    "Content-Length: #{content.bytesize}\r\n\r\n#{content}"
  end

  # Test initialize handshake
  def test_initialize
    puts "Testing LSP initialize handshake..."
    
    request = build_request("initialize", {
      processId: Process.pid,
      clientInfo: {
        name: "MAL Ruby LSP Test",
        version: "0.1.0"
      },
      rootUri: "file://#{Dir.pwd}",
      capabilities: {
        textDocument: {
          completion: {
            dynamicRegistration: false
          },
          hover: {
            dynamicRegistration: false
          },
          definition: {
            dynamicRegistration: false
          }
        }
      }
    })
    
    # TODO: Send request to Ruby LSP server
    # TODO: Validate response contains server capabilities
    
    puts "  ✓ Initialize request built"
    request
  end

  # Test document synchronization
  def test_document_sync
    puts "Testing document synchronization..."
    
    mal_code = File.read("../../mal_minimal.rb") rescue "def test; end"
    
    request = build_request("textDocument/didOpen", {
      textDocument: {
        uri: "file://#{Dir.pwd}/mal_minimal.rb",
        languageId: "ruby",
        version: 1,
        text: mal_code[0..500] # First 500 chars
      }
    })
    
    puts "  ✓ Document open request built"
    request
  end

  # Test completion request
  def test_completion
    puts "Testing completion..."
    
    request = build_request("textDocument/completion", {
      textDocument: {
        uri: "file://#{Dir.pwd}/mal_minimal.rb"
      },
      position: {
        line: 10,
        character: 5
      }
    })
    
    puts "  ✓ Completion request built"
    request
  end

  # Test hover request
  def test_hover
    puts "Testing hover..."
    
    request = build_request("textDocument/hover", {
      textDocument: {
        uri: "file://#{Dir.pwd}/mal_minimal.rb"
      },
      position: {
        line: 50,
        character: 10
      }
    })
    
    puts "  ✓ Hover request built"
    request
  end

  # Run all tests
  def run_all_tests
    puts "LSP Protocol Test Suite"
    puts "======================="
    puts ""
    
    test_initialize
    puts ""
    
    test_document_sync
    puts ""
    
    test_completion
    puts ""
    
    test_hover
    puts ""
    
    puts "All protocol tests completed!"
    puts ""
    puts "Note: This is a planning phase. Actual server communication"
    puts "will be implemented in the next phase."
  end
end

if __FILE__ == $0
  tester = LSPProtocolTest.new
  tester.run_all_tests
end