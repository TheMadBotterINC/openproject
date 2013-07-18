#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe WorkPackagesHelper do
  let(:stub_work_package) { FactoryGirl.build_stubbed(:planning_element) }

  describe :work_package_breadcrumb do
    it 'should provide a link to index as the first element and all ancestors as links' do
      index_link = double('work_package_index_link')
      ancestors_links = double('ancestors_links')

      helper.stub!(:ancestors_links).and_return([ancestors_links])
      helper.stub!(:work_package_index_link).and_return(index_link)

      @expectation = [index_link, ancestors_links]

      helper.should_receive(:breadcrumb_paths).with(*@expectation)

      helper.work_package_breadcrumb
    end
  end

  describe :ancestors_links do
    it 'should return a list of links for every ancestor' do
      ancestors = [mock('ancestor1', id: 1),
                   mock('ancestor2', id: 2)]

      controller.stub!(:ancestors).and_return(ancestors)

      ancestors.each_with_index do |ancestor, index|
        helper.ancestors_links[index].should have_selector("a[href='#{work_package_path(ancestor.id)}']", :text => "##{ancestor.id}")

      end
    end
  end

  describe :work_package_index_link do
    it "should return a link to issue_index (work_packages index later)" do
      helper.work_package_index_link.should have_selector("a[href='#{issues_path}']", :text => I18n.t(:label_issue_plural))
    end
  end

  describe :work_package_form_issue_category_attribute do
    let(:stub_project) { FactoryGirl.build_stubbed(:project) }
    let(:stub_category) { FactoryGirl.build_stubbed(:issue_category) }
    let(:form) { double('form', :select => "").as_null_object }

    before do
      # set sensible defaults
      stub!(:authorize_for).and_return(false)
      stub_project.stub!(:issue_categories).and_return([stub_category])
    end

    it "should return nothing if the project has no categories assigned" do
      stub_project.stub!(:issue_categories).and_return([])

      work_package_form_issue_category_attribute(form, stub_work_package, :project => stub_project).should be_nil
    end

    it "should have a :category symbol as the attribute" do
      work_package_form_issue_category_attribute(form, stub_work_package, :project => stub_project).attribute.should == :category
    end

    it "should render a select with the project's issue category" do
      select = double('select')

      form.should_receive(:select).with(:category_id,
                                        [[stub_category.name, stub_category.id]],
                                        :include_blank => true).and_return(select)

      work_package_form_issue_category_attribute(form, stub_work_package, :project => stub_project).field.should == select
    end

    it "should add an additional remote link to create new categories if allowed" do
      remote = "remote"

      stub!(:authorize_for).and_return(true)

      should_receive(:prompt_to_remote).with(*([anything()] * 3), project_issue_categories_path(stub_project), anything()).and_return(remote)

      work_package_form_issue_category_attribute(form, stub_work_package, :project => stub_project).field.should include(remote)
    end
  end

  describe :work_package_css_classes do
    it "should always have the work_package class" do
      helper.work_package_css_classes(stub_work_package).should include("work_package")
    end

    it "should return the position of the work_package's status" do
      status = double('status', :is_closed? => false)

      stub_work_package.stub!(:status).and_return(status)
      status.stub!(:position).and_return(5)

      helper.work_package_css_classes(stub_work_package).should include("status-5")
    end

    it "should not have a status class if the work_package has none" do
      helper.work_package_css_classes(stub_work_package).should_not include("status")
    end

    it "should return the position of the work_package's priority" do
      priority = double('priority')

      stub_work_package.stub!(:priority).and_return(priority)
      priority.stub!(:position).and_return(5)

      helper.work_package_css_classes(stub_work_package).should include("priority-5")
    end

    it "should not have a priority class if the work_package has none" do
      helper.work_package_css_classes(stub_work_package).should_not include("priority")
    end

    it "should have a closed class if the work_package is closed" do
      stub_work_package.stub!(:closed?).and_return(true)

      helper.work_package_css_classes(stub_work_package).should include("closed")
    end

    it "should not have a closed class if the work_package is not closed" do
      stub_work_package.stub!(:closed?).and_return(false)

      helper.work_package_css_classes(stub_work_package).should_not include("closed")
    end

    it "should have an overdue class if the work_package is overdue" do
      stub_work_package.stub!(:overdue?).and_return(true)

      helper.work_package_css_classes(stub_work_package).should include("overdue")
    end

    it "should not have an overdue class if the work_package is not overdue" do
      stub_work_package.stub!(:overdue?).and_return(false)

      helper.work_package_css_classes(stub_work_package).should_not include("overdue")
    end

    it "should have a child class if the work_package is a child" do
      stub_work_package.stub!(:child?).and_return(true)

      helper.work_package_css_classes(stub_work_package).should include("child")
    end

    it "should not have a child class if the work_package is not a child" do
      stub_work_package.stub!(:child?).and_return(false)

      helper.work_package_css_classes(stub_work_package).should_not include("child")
    end

    it "should have a parent class if the work_package is a parent" do
      stub_work_package.stub!(:leaf?).and_return(false)

      helper.work_package_css_classes(stub_work_package).should include("parent")
    end

    it "should not have a parent class if the work_package is not a parent" do
      stub_work_package.stub!(:leaf?).and_return(true)

      helper.work_package_css_classes(stub_work_package).should_not include("parent")
    end

    it "should have a created-by-me class if the work_package is a created by the current user" do
      stub_user = double('user', :logged? => true, :id => 5)
      User.stub!(:current).and_return(stub_user)
      stub_work_package.stub!(:author_id).and_return(5)

      helper.work_package_css_classes(stub_work_package).should include("created-by-me")
    end

    it "should not have a created-by-me class if the work_package is not created by the current user" do
      stub_user = double('user', :logged? => true, :id => 5)
      User.stub!(:current).and_return(stub_user)
      stub_work_package.stub!(:author_id).and_return(4)

      helper.work_package_css_classes(stub_work_package).should_not include("created-by-me")
    end

    it "should not have a created-by-me class if the work_package is the current user is not logged in" do
      helper.work_package_css_classes(stub_work_package).should_not include("created-by-me")
    end

    it "should have a assigned-to-me class if the work_package is a created by the current user" do
      stub_user = double('user', :logged? => true, :id => 5)
      User.stub!(:current).and_return(stub_user)
      stub_work_package.stub!(:assigned_to_id).and_return(5)

      helper.work_package_css_classes(stub_work_package).should include("assigned-to-me")
    end

    it "should not have a assigned-to-me class if the work_package is not created by the current user" do
      stub_user = double('user', :logged? => true, :id => 5)
      User.stub!(:current).and_return(stub_user)
      stub_work_package.stub!(:assigned_to_id).and_return(4)

      helper.work_package_css_classes(stub_work_package).should_not include("assigned-to-me")
    end

    it "should not have a assigned-to-me class if the work_package is the current user is not logged in" do
      helper.work_package_css_classes(stub_work_package).should_not include("assigned-to-me")
    end
  end
end
