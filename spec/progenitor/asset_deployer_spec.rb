require 'progenitor/asset_deployer'

describe Progenitor::AssetDeployer do
  let(:remote_user_1) { 'dick' }
  let(:remote_user_2) { 'jane' }
  let(:rsa_private_key) { 'some/path' }
  let(:asset_location) { 'boom/shaka/laka' }
  let(:valid_asset_folder_1) { 'valid-folder-1' }
  let(:valid_asset_folder_2) { 'valid-folder-2' }
  let(:ip_1) { '172.3.2.34' }
  let(:ip_2) { '192.168.1.1' }
  let(:destination_1) { '/destination-path/1' }
  let(:destination_2) { '/destination-path/2' }
  let(:player_1) { mock("player 1", :host => ip_1, :username => remote_user_1, :deploy_path => destination_1, :sudo => true) }
  let(:player_2) { mock("player 2", :host => ip_2, :username => remote_user_2, :deploy_path => destination_2, :sudo => false) }
  let(:deployer) { described_class.new(rsa_private_key, asset_location) }

  before :each do
    described_class.any_instance.stub( :system )
    valid_path_1 = "#{asset_location}/#{valid_asset_folder_1}"
    valid_path_2 = "#{asset_location}/#{valid_asset_folder_2}"

    Dir.stub(:glob)
      .with( "#{asset_location}/*" )
      .and_return([valid_path_1, valid_path_2])

    File.stub(:directory?).with(anything()).and_return(false)
    File.stub(:directory?).with(valid_path_1).and_return(true)
    File.stub(:directory?).with(valid_path_2).and_return(true)
  end

  it 'SSH copies folder to given ip' do
    set_scp_expectation( deployer, ip_1, valid_asset_folder_1, destination_1, remote_user_1 )
    deployer.deploy( player_1, valid_asset_folder_1 )
  end

  it 'restarts the remote SpallaApp' do
    set_scp_expectation( deployer, ip_1, valid_asset_folder_1, destination_1, remote_user_1 )
    set_ssh_expectation( deployer, './killSpallaApp.sh', ip_1, remote_user_1 )
    set_ssh_expectation( deployer, './startSpallaApp.sh', ip_1, remote_user_1 )
    deployer.deploy( player_1, valid_asset_folder_1 )
  end

  it 'restarts the remote SpallaApp without sudo' do
    set_scp_expectation( deployer, ip_2, valid_asset_folder_1, destination_2, remote_user_2 )
    set_ssh_expectation( deployer, './killSpallaApp.sh', ip_2, remote_user_2, false )
    set_ssh_expectation( deployer, './startSpallaApp.sh', ip_2, remote_user_2, false )
    deployer.deploy( player_2, valid_asset_folder_1 )
  end

  it 'handles multiple ips' do
    set_scp_expectation( deployer, ip_1, valid_asset_folder_1, destination_1, remote_user_1 )
    set_scp_expectation( deployer, ip_2, valid_asset_folder_1, destination_2, remote_user_2 )
    deployer.deploy( [player_1, player_2], valid_asset_folder_1 )
  end

  it 'handles multiple folders' do
    set_scp_expectation( deployer, ip_1, valid_asset_folder_1, destination_1, remote_user_1 )
    set_scp_expectation( deployer, ip_1, valid_asset_folder_2, destination_1, remote_user_1 )
    deployer.deploy( player_1, [valid_asset_folder_1, valid_asset_folder_2] )
  end

  it 'ignores files not in the asset_location folder' do
    set_scp_expectation( deployer, ip_1, valid_asset_folder_1, destination_1, remote_user_1 )
    set_scp_expectation( deployer, ip_1, valid_asset_folder_2, destination_1, remote_user_1 )
    set_scp_anti_expectation( deployer, ip_1, '../garbage', destination_1, remote_user_1 )
    deployer.deploy( player_1, [valid_asset_folder_1, valid_asset_folder_2, '../garbage'] )
  end

  it 'handles nils' do
    deployer.should_not_receive(:system)
    deployer.deploy( nil, valid_asset_folder_1 )
    deployer.deploy( player_1, nil )
    deployer.deploy( nil, nil )
  end

  it 'lists available asset folders' do
    deployer.available_assets.should == [valid_asset_folder_1, valid_asset_folder_2]
  end

  def set_scp_expectation( deployer, ip, source_folder, destination, remote_user )
    expectation = deployer.should_receive(:system)
    with_scp_parameters( expectation, deployer, ip, source_folder, destination, remote_user )
  end

  def set_scp_anti_expectation( deployer, ip, source_folder, destination, remote_user )
    expectation = deployer.should_not_receive(:system)
    with_scp_parameters( expectation, deployer, ip, source_folder, destination, remote_user )
  end

  def with_scp_parameters( expectation, deployer, ip, source_folder, destination, remote_user )
    expectation.with('scp',
      '-r',
      '-o', 'UserKnownHostsFile=/dev/null',
      '-o', 'StrictHostKeyChecking=no',
      '-i', rsa_private_key,
      asset_location + '/' + source_folder + "/.",
      remote_user + "@" + ip + ":" + destination + "/.")
  end

  def set_ssh_expectation( deployer, command, ip, remote_user, sudo = true )
     with = ['ssh',
        '-i', rsa_private_key,
        '-o', 'UserKnownHostsFile=/dev/null',
        '-o', 'StrictHostKeyChecking=no',
        "#{remote_user}@#{ip}"]
     with << 'sudo' if sudo
     with << command

    deployer.should_receive(:system)
      .with(*with)
  end
end

