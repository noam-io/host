
module Progenitor
  class AssetDeployer
    def initialize(remote_user, rsa_private_key, asset_location, destination)
     @remote_user = remote_user
     @rsa_private_key = rsa_private_key
     @asset_location = asset_location
     @destination = destination
   end

    def deploy( ips, folders )
      ips = [] unless ips
      ips = [ips] unless ips.is_a? Array
      folders = [folders] unless folders.is_a? Array

      folders = filter_bogus_folders( folders )
      ips.product(folders) do |ip, folder|
        scp_folder_to( folder, ip )
        execute_over_ssh( "./killSpallaApp.sh", ip )
        execute_over_ssh( "./startSpallaApp.sh", ip )
      end
    end

    def available_assets
      Dir.glob("#{@asset_location}/*")
        .select{ |path| File.directory? path }
        .map{ |path| File.basename path }
    end

    private

    def execute_over_ssh( command, ip )
      system('ssh', '-i', @rsa_private_key, "#{@remote_user}@#{ip}", "sudo", command )
    end

    def scp_folder_to( folder, ip )
      system("scp", "-r", "-i", @rsa_private_key, "#{@asset_location}/#{folder}/.", "#{@remote_user}@#{ip}:#{@destination}/.")
    end

    def filter_bogus_folders( folders )
      folders & available_assets
    end
  end
end

