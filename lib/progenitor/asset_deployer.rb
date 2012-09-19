
module Progenitor
  class AssetDeployer
    def initialize(remote_user, private_key, asset_location, destination)
     @remote_user = remote_user
     @private_key = private_key
     @asset_location = asset_location
     @destination = destination
   end

    def deploy( ips, folder )
      ips.each { |ip| run_scp(ip, folder) } if ips.is_a? Array
      run_scp(ips, folder) unless ips.is_a? Array
    end

    private

    def run_scp( ip, folder )
      system("scp", "-r", "-i", @private_key, "#{@asset_location}/#{folder}/.", "#{@remote_user}@#{ip}:#{@destination}/.")
    end
  end
end

