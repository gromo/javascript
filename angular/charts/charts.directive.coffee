'use strict'

# https://developers.google.com/chart/interactive/docs/gallery/geochart

angular.module "i4Research"
.directive "googleChart", (GoogleCharts) ->
  # return
  link: (scope, element, attrs) ->
    chart = null

    updateChart = ->
      if chart and scope.data
        chartData = scope.data
        scope.title = scope.chart.getTitle()
        if chartData not instanceof google.visualization.DataTable
          chartData = google.visualization.arrayToDataTable scope.data
        chartOptions = scope.chart.getGoogleChartOptions()
        chart.draw chartData, chartOptions

    scope.saveChartAsHtml = ()->
      if chart and scope.data
        data = scope.chart.getExportData()
        table = []
        data.forEach (row, i)->
          tr = []
          row.forEach (cell, c)->
            tr.push if i then "<td>#{cell}</td>" else "<th>#{cell}</th>"
          table.push '<tr>' + tr.join('') + '</tr>'
        
        head = [
          '<title>' + scope.chart.getTitle() + '</title>'
          '<style type="text/css">body{margin:0 auto;text-align:center;width:860px;}table{border-collapse:collapse;margin:0 auto;}td,th{border:1px solid #CCC;padding:3px 4px;}td{text-align:right;}td:first-child{text-align:left;}</style>'
        ]
        image = '<img src="' + chart.getImageURI() + '">'
        table = '<table>' + (table.join '') + '</table>'
        title = '<h1>' + scope.chart.getTitle() + '</h1>'
        
        data = new Blob ['<html><head>' + head.join('') + '</head><body>' + title + image + table + '</body></html>'], {type: "text/html"}
        saveAs data, "chart.html"
      true
    
    scope.$watch 'data', updateChart

    GoogleCharts.load().then () ->
      chartElement = $('<div style="height:460px;"></div>')
      element.find('.chart').replaceWith chartElement
      chart = scope.chart.getGoogleChart chartElement.get 0
      updateChart()
      
      element.on '$destroy', () ->
        chart.clearChart()
  restrict: "A"
  scope:
    chart: '=googleChart'
    data: '=googleChartData'
  templateUrl: "/app/charts/charts.directive.html"