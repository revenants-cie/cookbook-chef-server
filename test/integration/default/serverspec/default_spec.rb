require 'serverspec'

set :backend, :exec

describe 'chef server' do
    it 'responds on port 80' do
        expect(port 80).to be_listening 'tcp'
    end
    it 'responds on port 443' do
        expect(port 443).to be_listening 'tcp'
    end
end
