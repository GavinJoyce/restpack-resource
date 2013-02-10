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
    
    pending "handles unfound ids"
    
    it "return correct model #as_resource" do
      result = Song.single_resource({ :id => @song.id })
      result[:id].should == @song.id
      result[:url].should == "/api/v1/songs/#{@song.id}"
    end
    
    it "sideloads ManyToOne" do
      result = Song.single_resource(:id => @song.id, :includes => 'artists')
      result[:id].should == @song.id
      
      result[:artists].should_not == nil
      result[:artists].count.should == 1
      result[:artists][0][:url].should == "/api/v1/artists/#{@song.artist.id}"
    end
    
    describe "OneToMany" do
      before(:each) do
        @artist = create(:artist)
        3.times { create(:song, :artist => @artist) }
      end
      
      it "sideloads OneToMany relations" do
        result = Artist.single_resource(:id => @artist.id, :includes => 'songs')
        result[:id].should == @artist.id
      
        result[:songs].should_not == nil
        result[:songs].count.should == 3
      end
    end

  end
end