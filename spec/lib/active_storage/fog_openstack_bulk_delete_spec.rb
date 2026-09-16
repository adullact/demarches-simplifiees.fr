# frozen_string_literal: true

require 'rails_helper'

# Guards the monkeypatch in config/initializers/active_storage.rb that repairs
# fog-openstack's `delete_multiple_objects` (broken by the removal of URI.encode
# in Ruby 3.0).
describe Fog::OpenStack::Storage::Real, '#delete_multiple_objects' do
  subject(:real) { described_class.allocate }

  let(:captured) { {} }

  before do
    allow(real).to receive(:request) do |params, _|
      captured.merge!(params)
      Struct.new(:body).new('{"Number Deleted": 2, "Errors": []}')
    end
  end

  it 'does not raise (URI.encode is gone) and escapes each path, keeping the slash literal' do
    expect { real.delete_multiple_objects('bucket', ['key one', 'variants/abc/def']) }
      .not_to raise_error

    expect(captured[:body]).to eq("bucket/key%20one\nbucket/variants/abc/def")
    expect(captured[:query]).to eq('bulk-delete' => true)
    expect(captured[:method]).to eq('DELETE')
  end

  it 'decodes the JSON response body' do
    response = real.delete_multiple_objects('bucket', ['key'])

    expect(response.body).to eq('Number Deleted' => 2, 'Errors' => [])
  end

  # Canaries: the monkeypatch is only needed while BOTH remain true — Ruby lacks
  # URI.encode AND fog-openstack still calls it. When either stops holding, the
  # matching test fails: that is the signal to delete the patch and these tests.
  describe 'monkeypatch necessity' do
    it 'URI.encode is still undefined in this Ruby' do
      expect { URI.encode('x') }.to raise_error(NoMethodError)
    end

    it 'fog-openstack still ships the broken URI.encode call' do
      source_file = File.join(
        Gem.loaded_specs.fetch('fog-openstack').gem_dir,
        'lib/fog/openstack/storage/requests/delete_multiple_objects.rb'
      )

      expect(File.read(source_file)).to include('URI.encode')
    end
  end
end

# The stub above pins the request; only a real socket pins that fog hands the
# retry options over to Excon.
describe Fog::OpenStack::Storage::Real, '#delete_multiple_objects against a real HTTP server' do
  subject(:real) do
    Fog::OpenStack::Storage.new(
      openstack_auth_token: 'token',
      openstack_auth_url: "http://127.0.0.1:#{port}/v3",
      openstack_management_url: "http://127.0.0.1:#{port}/v1/AUTH_test"
    )
  end

  let(:server) { TCPServer.new('127.0.0.1', 0) }
  let(:port) { server.addr[1] }
  let(:bodies) { [] }

  let(:bad_gateway) do
    body = 'Timeout while waiting for response'
    "HTTP/1.1 502 Bad Gateway\r\nContent-Type: text/plain\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}"
  end
  let(:ok) do
    body = '{"Number Deleted": 1, "Number Not Found": 1, "Errors": []}'
    "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}"
  end

  before { stub_const('OpenStackBulkDeletePatch::RETRY_INTERVAL', 0) }
  after { server.close }

  # Answers one connection per response, recording each request body.
  def serve(*responses)
    Thread.new do
      responses.each do |response|
        socket = server.accept
        content_length = 0
        while (line = socket.gets) && line != "\r\n"
          content_length = line.split(': ', 2).last.to_i if line.downcase.start_with?('content-length')
        end
        bodies << socket.read(content_length)
        socket.write(response)
        socket.close
      end
    end
  end

  it 'replays the request after a ds_proxy timeout (502) and returns the decoded body' do
    thread = serve(bad_gateway, ok)

    response = real.delete_multiple_objects('bucket', ['a', 'b'])
    thread.join(5)

    expect(response.body).to eq('Number Deleted' => 1, 'Number Not Found' => 1, 'Errors' => [])
    expect(bodies).to eq(["bucket/a\nbucket/b", "bucket/a\nbucket/b"])
  end

  it 'gives up once the retries are spent' do
    thread = serve(*[bad_gateway] * Excon.defaults[:retry_limit])

    expect { real.delete_multiple_objects('bucket', ['a']) }.to raise_error(Excon::Error::BadGateway)
    thread.join(5)

    expect(bodies.size).to eq(Excon.defaults[:retry_limit])
  end
end
