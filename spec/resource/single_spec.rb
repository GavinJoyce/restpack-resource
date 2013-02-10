require './spec/spec_helper'

describe RestPack::Resource do
  describe "#single_resource" do
    before(:each) do
      @song = create(:song)
    end
    
    it "requires an id" do
      expect do
        Song.single_resource()
      end.to raise_error(RestPack::Resource::InvalidArguments, "id must be specified")
    end
    
    it "return correct model #as_resource" do
      result = Song.single_resource({ :id => @song.id })
      result[:id].should == @song.id
      result[:url].should == "/api/v1/songs/#{@song.id}"
    end

  end
end