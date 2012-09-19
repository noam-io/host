
module Progenitor
  class AssetDeployer
    def initialize(remote_user, private_key, asset_location, destination)
     @remote_user = remote_user
     @private_key = private_key
     @asset_location = asset_location
     @destination = destination
   end

    def deploy( ips, folders )
      ips = [ips] unless ips.is_a? Array
      folders = [folders] unless folders.is_a? Array

      ips.product(folders) do |ip, folder|
        run_scp(ip, folder)
      end
    end

    private

    def run_scp( ip, folder )
      system("scp", "-r", "-i", @private_key, "#{@asset_location}/#{folder}/.", "#{@remote_user}@#{ip}:#{@destination}/.")
    end
  end
end

