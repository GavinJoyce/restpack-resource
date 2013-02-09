require './spec/spec_helper'
require './lib/restpack-resource'

describe RESTpack::Resource do
  describe "#resource_paged_resource" do 
    context "when filtering" do
      context "with invalid options" do
        it "should not allow invalid filters" do
          expect { Artist.resource_paged_resource(:filters => {:this_is_invalid => 4}) }.to raise_error(RESTpack::Resource::InvalidFilter)
        end
      end
      
      context "with valid options" do
        it "should filter results" do
          @gavin = User.create(name: 'Gavin')
          @sarah = User.create(name: 'Sarah')
          @artist = Artist.create(:name => 'Radiohead')
          @codex = Song.create(:name => 'Codex', :artist => @artist, :creator => @gavin, :modifier => @sarah)
          @bloom = Song.create(:name => 'Bloom', :artist => @artist)
          @gagging_order = Song.create(:name => 'Gagging Order', :artist => @artist)

          25.times do |i|
            artist = Artist.create(name: "Artist #{i}")
            song1 = Song.create(name: "Song #{i}.1", artist: artist)
            song2 = Song.create(name: "Song #{i}.2", artist: artist)
            comment = Comment.create(:text => 'This is fansastic live', :song => song2)
          end
          
          result = Song.resource_paged_resource(:filters => {:artist_id => @artist.id})
          result[:total].should == 3
        end
      end
    end
  end
end