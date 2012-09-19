require 'progenitor/asset_deployer'

describe Progenitor::AssetDeployer do
  let(:remote_user) { 'bob' }
  let(:private_key) { 'some/path' }
  let(:asset_location) { 'boom/shaka/laka' }
  let(:destination) { '/destination-path' }
  let(:deployer) { described_class.new(remote_user, private_key, asset_location, destination) }

  it 'SSH copies folders to given ip' do
    ip = '172.03.2.3'
    source_folder = 'another-path'

    set_expectation( ip, source_folder )

    deployer.deploy(ip, source_folder)
  end

  it 'handles multiple ips' do
    ips = ['172.03.2.3', '192.168.1.1']
    source_folder = 'another-path'

    ips.each do |ip|
      set_expectation( ip, source_folder )
    end

    deployer.deploy(ips, source_folder)
  end

  it 'handles multiple folders' do
    ip = '172.03.2.3'
    source_folders = ['f1', 'f2']

    source_folders.each do |source_folder|
      set_expectation( ip, source_folder )
    end

    deployer.deploy(ip, source_folders)
  end

  def set_expectation( ip, source_folder )
    deployer.should_receive(:system)
      .with('scp', '-r', '-i', private_key,
      asset_location + '/' + source_folder + "/.",
      remote_user + "@" + ip + ":" + destination + "/.")
  end
end

