'use strict'

# https://developers.google.com/chart/interactive/docs/gallery/geochart
# TODO:
# 1. do not remove <base> tag
# 2. do not use directive - handle google chart in controller

angular.module "i4Research"
.controller "ChartsCtrl", ($scope, $rootScope, $modal, GoogleCharts, Charts, Data, Project, Study)->

  $rootScope.dataObtained = true # hide global loading
  GoogleCharts.load() #preload google charts

  # constant labels
  LABEL =
    "LOADING": "Loading..."
    "NO_OPTIONS":
      "": "-- No Options --"
      "BEAT": "-- No Beats --"
      "CUSTOMER": "-- No Clients --"
      "PERIOD": "-- No Periods --"
      "PROJECT": "-- No Projects --"
      "STUDY": "-- No Studies --"
      "ZONE": "-- No Zones --"
    "SELECT":
      "": "-- Select --"
      "BEAT": "-- Select Beat --"
      "CUSTOMER": "-- Select Client --"
      "PERIOD": "-- Select Period --"
      "PROJECT": "-- Select Project --"
      "STUDY": "-- Select Study --"
      "ZONE": "-- Select Zone --"

  # scope variables
  $scope.charts = Charts.getCharts()
  $scope.filters =
    "beat": null
    "customer": null
    "groupby": null
    "period": null
    "project": null
    "report": null
    "study": null
    "zone": null
  $scope.inProgress = false
  $scope.isReadyToGenerate = false
  $scope.label =
    "beat": LABEL.SELECT.BEAT
    "groupby": LABEL.SELECT
    "period": LABEL.SELECT.STUDY
    "project": LABEL.LOADING
    "study": LABEL.SELECT.PROJECT
    "zone": LABEL.SELECT.ZONE
  $scope.selected =
    "beat": null
    "chart": null
    "customer": null
    "datefrom": null
    "dateto": null
    "groupby": null
    "options": {}
    "period": null
    "project": null
    "report": null
    "study": null
    "zone": null

  # datepickers
  $scope.datepickers =
    datefrom:
      open: ($event)->
        $event.preventDefault()
        $event.stopPropagation()
        $scope.datepickers.datefrom.opened = true
      opened: false
    dateto:
      open: ($event)->
        $event.preventDefault()
        $event.stopPropagation()
        $scope.datepickers.dateto.opened = true
      opened: false



  # watch chart here
  $scope.$watch "selected.chart", (chart)->
    if chart
      # set chart active, reset others
      angular.forEach $scope.charts, (chart)->
        chart.active = false
      chart.active = true

      # init chart
      if chart.init
        chart.init $scope.selected
        $scope.filters = chart.getFilters()
    true



  # register selected watchers here
  angular.forEach $scope.selected, (value, name)->
    if name isnt "chart" # but not chart!
      $scope.$watch "selected." + name, (object)->
        chart = $scope.selected.chart
        func = "set" + name.charAt(0).toUpperCase() + name.slice 1

        # update data based on selected object
        if chart and chart[func]
          chart[func] object

        $scope.message = ''
        $scope.updateGenerateButton()
        true
    true



  # listen for options to update labels
  angular.forEach $scope.label, (label, name)->
    $scope.$watch "filters.#{name}.options", (options)->
      label = LABEL.SELECT[name.toUpperCase()] or LABEL.SELECT['']
      if options
        if options.then # is promise
          label = LABEL.LOADING
          options.catch (response)->
            $scope.message = "Cannot load #{name} options"
        else
          if not options.length
            label = LABEL.NO_OPTIONS[name.toUpperCase()] or LABEL.NO_OPTIONS['']
      $scope.label[name] = label



  $scope.generateReport = ()->

    chart = $scope.selected.chart
    $scope.inProgress = true
    $scope.message = ''

    Data.getReport chart.getReportType(), chart.getSubmitData()
    .then (data)->
      if data.length == 0
        $scope.message = "No valid data to generate the chart"
        return
      try
        chart.setData data
        $scope.chartData = chart.getChartData()
      catch error
        $scope.message = error.message
        return
      $modal.open
        "scope": $scope
        "size": 'lg'
        "template": '<div data-google-chart="selected.chart" data-google-chart-data="chartData" style="padding: 20px;"></div>'
        #"templateUrl": "/app/charts/modal.html"
    .catch (response)->
      message = response.message or response.error
      $scope.message = "Report cannot be generated: " + message
    .finally ()->
      $scope.inProgress = false



  $scope.selectChart = (chart)->
    if not chart.disabled
      $scope.selected.chart = chart



  $scope.updateGenerateButton = ()->
    isReady = false
    selected = $scope.selected
    if selected.chart
      isReady = true
      angular.forEach $scope.filters, (filter, name)->
        if filter and filter.visible and filter.required
          if not selected[name] or (name is 'groupby' and selected.groupby.types and (selected.groupby.types.filter (type)-> type.selected).length == 0)
            isReady = false
      if isReady and selected.chart.isReady and not selected.chart.isReady()
        isReady = false
    $scope.isReadyToGenerate = isReady