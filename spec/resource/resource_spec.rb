require './spec/spec_helper'
require './lib/restpack-resource'

describe RestPack::Resource do
  context "Resource Setup" do
    before :each do
      class MyModel
        include DataMapper::Resource
        include RestPack::Resource
        property :id, Serial
        property :name, String
        property :age, Integer
      end
      DataMapper.auto_migrate!
    end
    
    describe "#resource_can_include" do
      it "allows association to be set" do
        MyModel.resource_includable_associations.length == 0
        class MyModel        
          resource_can_include :association1
          resource_can_include :association2, :association3, :association3
        end
        MyModel.resource_includable_associations.should == [:association1, :association2, :association3]
      end
    end
  
   describe "#resource_can_filter_by" do
     it "allows filterable columns to be set" do
       MyModel.resource_filterable_by.length == 0
       class MyModel        
         resource_can_filter_by :id
         resource_can_filter_by :name, :age
         resource_can_filter_by :name, :age
       end
       MyModel.resource_filterable_by.should == [:id, :name, :age]
     end
   end
  
   describe "#resource_can_sort_by" do
     it "allows sortable columns to be set" do
       MyModel.resource_sortable_by.length == 0
       class MyModel        
         resource_can_sort_by :id
         resource_can_sort_by :name, :age, :id
       end
       MyModel.resource_sortable_by.should == [:id, :name, :age]
     end
   end
  end
end