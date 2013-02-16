require './spec/spec_helper'

describe RestPack::Resource do
  describe "#paged_resource" do 
    context "when filtering" do      
      context "with valid options" do
        before(:each) do
          @artist = create(:artist)
          3.times { create(:song, artist: @artist) }
          9.times { create(:song) }
        end
        
        it "should return the total count" do
          result = Song.paged_resource()
          result[:count].should == 12
        end
        
        it "should filter results" do
          result = Song.paged_resource(filters: { artist_id: @artist.id } )
          result[:count].should == 3
        end
      end
    end
  end
end