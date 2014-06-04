//-- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

describe('sortHeader Directive', function() {
    var compile, element, rootScope, scope;

    beforeEach(angular.mock.module('openproject.workPackages.directives'));
    beforeEach(module('templates', 'openproject.models'));

    beforeEach(inject(function($rootScope, $compile) {
      var header1Html;
      header1Html = '<th sort-header sortable="true" query="query" header-name="headerName1" header-title="headerTitle1"></th>';
      var header2Html;
      header2Html = '<th sort-header sortable="true" query="query" header-name="headerName2" header-title="headerTitle2"></th>';

      element1 = angular.element(header1Html);
      element2 = angular.element(header2Html);
      rootScope = $rootScope;
      scope = $rootScope.$new();

      compile = function() {
        $compile(element1)(scope);
        $compile(element2)(scope);
        scope.$digest();
      };
    }));

    describe('element', function() {
      var Sortation;
      beforeEach(inject(function(_Sortation_) {
        Sortation = _Sortation_;
      }));

      describe('rendering multiple headers', function(){
        beforeEach(function(){
          var query = new Query({
          });
          query.setSortation(new Sortation([]));
          scope.query = query;

          compile();
        });

        it('should render a th', function() {
          expect(element1.prop('tagName')).to.equal('TH');
          expect(element2.prop('tagName')).to.equal('TH');
        });

        it('should contain header titles', function() {
          scope.headerName1 = 'status';
          scope.headerTitle1 = 'Status';
          scope.headerName2 = 'type';
          scope.headerTitle2 = 'Type';
          scope.$apply();

          var link2 = element2.find('span a').first();
          expect(link2.text()).to.equal('Type');

          var link1 = element1.find('span a').first();
          expect(link1.text()).to.equal('Status');
        });

        xit('should add ascending/descending sort classes to header', function() {
          scope.headerName1 = 'status';
          scope.headerTitle1 = 'Status';
          scope.$apply();

          var link1 = element1.find('span a').first();
          expect(link1.hasClass('sort asc')).to.not.be.ok;

          link1.click();
          expect(link1.hasClass('sort asc')).to.be.ok;

          link1.click();
          expect(link1.hasClass('sort desc')).to.be.ok;
        });

        xit('should remove sort classes from other header', function() {
          scope.headerName1 = 'status';
          scope.headerTitle1 = 'Status';
          scope.headerName2 = 'type';
          scope.headerTitle2 = 'Type';
          scope.$apply();

          var link1 = element1.find('span a').first();
          link1.click();
          expect(link1.hasClass('sort asc')).to.be.ok;

          var link2 = element2.find('span a').first();
          link2.click();
          expect(link2.hasClass('sort asc')).to.be.ok;
          expect(link1.hasClass('sort asc')).to.not.be.ok;
        });
      });

    });
});
