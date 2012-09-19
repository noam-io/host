
module Progenitor
  class AssetDeployer
    def initialize(remote_user, private_key, asset_location, destination)
     @remote_user = remote_user
     @private_key = private_key
     @asset_location = asset_location
     @destination = destination
   end

    def deploy( ips, folders )
      ips = [] unless ips
      ips = [ips] unless ips.is_a? Array
      folders = [folders] unless folders.is_a? Array

      folders = filter_bogus_folders( folders )
      ips.product(folders) do |ip, folder|
        run_scp(ip, folder)
      end
    end

    private

    def run_scp( ip, folder )
      system("scp", "-r", "-i", @private_key, "#{@asset_location}/#{folder}/.", "#{@remote_user}@#{ip}:#{@destination}/.")
    end

    def filter_bogus_folders( folders )
      valid_folders = Dir.glob("#{@asset_location}/*")
                        .select{ |path| File.directory? path }
                        .map{ |path| File.basename path }
      folders & valid_folders
    end
  end
end

