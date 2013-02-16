require './spec/spec_helper'

describe RestPack::Service do
  let(:service) { "".extend(RestPack::Service) }
  
  describe "#paged_resource" do
    it "passes {} as options when there are no params" do
      Artist.should_receive(:paged_resource).with({})
      service.paged_resource(Artist, {})
    end
    
    context "with params" do
      it "extracts the page number" do
        Artist.should_receive(:paged_resource).with({ :page => 66 })
        service.paged_resource(Artist, { :page => '66' })
      end
      
      it "gives options[:page] precidence" do
        Artist.should_receive(:paged_resource).with({ :page => 2 })
        service.paged_resource(Artist, { :page => '66' }, { :page => 2 })
      end
      
      it "extracts the includes" do
        Artist.should_receive(:paged_resource).with({ :includes => [:songs, :manager] })
        service.paged_resource(Artist, { :includes => 'songs,manager' })
      end
      
      it "gives options[:includes] precidence" do
         Artist.should_receive(:paged_resource).with({ :includes => [:specified] })
          service.paged_resource(Artist, { :includes => 'songs,manager' }, { :includes => [:specified] })
      end
      
      it "extracts the sort_by" do
        Artist.should_receive(:paged_resource).with({ :sort_by => :id })
        service.paged_resource(Artist, { :sort_by => 'id' })
      end
      
      it "gives options[:sort_by] precidence" do
        Artist.should_receive(:paged_resource).with({ :sort_by => :name })
        service.paged_resource(Artist, { :sort_by => 'id' }, { :sort_by => :name })
      end
      
      it "extracts the sort_direction" do
        Artist.should_receive(:paged_resource).with({ :sort_direction => :ascending })
        service.paged_resource(Artist, { :sort_direction => 'ascending' })
      end
      
      it "gives options[:sort_direction] precidence" do
        Artist.should_receive(:paged_resource).with({ :sort_direction => :descending })
        service.paged_resource(Artist, { :sort_direction => 'ascending' }, { :sort_direction => :descending })
      end
      
      it "extracts the filters" do
        Artist.should_receive(:paged_resource).with({ :filters => { :id => '148258', :name => 'Radiohead' } })
        service.paged_resource(Artist, { :id => '148258', :name => 'Radiohead', :something => 'Else' })
      end
      
      it "gives options[:filters] precidence" do
        Artist.should_receive(:paged_resource).with({ :filters => { :id => '999' } })
        service.paged_resource(Artist, { :id => '148258', :name => 'Radiohead', :something => 'Else' }, { :filters => { :id => '999' }})
      end
    end
    
    
    describe "#single_resource" do
      it "passes {} as options when there are no params" do
        Artist.should_receive(:single_resource).with({})
        service.single_resource(Artist, {})
      end

      context "with params" do
        it "extracts the includes" do
          Artist.should_receive(:single_resource).with({ :includes => [:songs, :manager] })
          service.single_resource(Artist, { :includes => 'songs,manager' })
        end

        it "gives options[:includes] precidence" do
           Artist.should_receive(:single_resource).with({ :includes => [:specified] })
            service.single_resource(Artist, { :includes => 'songs,manager' }, { :includes => [:specified] })
        end
      end
    end
  end
end