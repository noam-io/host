require 'noam_server/server_name'

describe NoamServer::ServerName do
  it "uses the input name by default" do
    name = NoamServer::ServerName.new("Noam Moderator").to_s
    name.should == "Noam Moderator"
  end

  it "disallows brackets, @, quotes, etc." do
    name = NoamServer::ServerName.new("\"your\"@Noam]Moderator").to_s
    name.should == "-your--Noam-Moderator"
  end

  it "allows dots, underscores, and dashes" do
    name = NoamServer::ServerName.new("hi.there_Noam-Moderator").to_s
    name.should == "hi.there_Noam-Moderator"
  end

  it "trims to 128 characters" do
    name = NoamServer::ServerName.new("O"*1000).to_s
    name.should == "O"*128
  end
end
