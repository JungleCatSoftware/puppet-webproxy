require 'spec_helper'
describe 'webproxy' do

  context 'with defaults for all parameters' do
    it { should contain_class('webproxy') }
  end
end
