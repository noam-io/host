module NoamServer
  class AssetDeployer
    def initialize(rsa_private_key, asset_location)
      unless @rsa_private_key.nil?
        system('chmod', '600', rsa_private_key)
        @rsa_private_key = rsa_private_key
        @asset_location = asset_location
      else
        NoamLogging.warn(self, "No RSA private key found.")
      end
   end

    def deploy( players, folders )
      players = [] unless players
      players = [players] unless players.is_a? Array
      folders = [folders] unless folders.is_a? Array

      folders = filter_bogus_folders( folders )
      players.product(folders) do |player, folder|
        scp_folder_to( folder, player )
        execute_over_ssh( "./killSpallaApp.sh", player )
        execute_over_ssh( "./startSpallaApp.sh", player )
      end
    end

    def available_assets
      Dir.glob("#{@asset_location}/*")
        .select{ |path| File.directory? path }
        .map{ |path| File.basename path }
    end

    private

    def execute_over_ssh( command, player )
      command_args = [ 'ssh',
        '-i', @rsa_private_key,
        '-o', 'UserKnownHostsFile=/dev/null',
        '-o', 'StrictHostKeyChecking=no',
        "#{player.username}@#{player.host}"]
      command_args << "sudo" if player.sudo
      command_args << command
      system(*command_args)
    end

    def scp_folder_to( folder, player)
      system("scp",
        "-r",
        '-o', 'UserKnownHostsFile=/dev/null',
        '-o', 'StrictHostKeyChecking=no',
        "-i", @rsa_private_key, "#{@asset_location}/#{folder}/.",
        "#{player.username}@#{player.host}:#{player.deploy_path}/.")
    end

    def filter_bogus_folders( folders )
      folders & available_assets
    end
  end
end

