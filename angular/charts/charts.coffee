'use strict'

# https://developers.google.com/chart/interactive/docs/gallery/geochart

angular.module "i4Research"
.service "Charts", (Data, Study, Beat)->

  # helper
  helper =
    getById: (id, objects)->
      toReturn = null
      angular.forEach objects, (object)->
        if object.id == id
          toReturn = object
      toReturn

    getDate: (date)->
      #date = date.replace /^(\d{2,4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{1,2}):(\d{1,2}).?(\d{0,3}) \+(\d{2}):(\d{2})$/, '$1-$2-$3T$4:$5:$6+$8$9'
      #date = new Date Date.parse date
      date = moment date, 'YYYY-MM-DD HH:mm:ss.SSS ZZ'
      toReturn =
        date: date.format 'YYYY-MM-DD'
        time: date.format 'HH:mm'

    getDateGroup: (date)->
      date = helper.getDate date
      "#{date.date}\n#{date.time}"

    getDataByBeats: (data)->
      # variables
      beats = {}

      # group all data as hash
      data.forEach (entry) ->
        beatid = entry.beat.id
        if not beats[beatid]
          beats[beatid] =
            title: helper.getDateGroup entry.beat.datestart
        beats[beatid][entry.type || "total"] = entry.qty

      # return
      beats

    getDataGroupedByBeat: (data)->
      # variables
      grouped =
        beats: {}
        zones: {}
      # group all data as hash
      data.forEach (entry) ->
        beat = helper.getDateGroup entry.beat.datestart
        zoneid = entry.zone.id
        if not grouped.zones[zoneid]
          grouped.zones[zoneid] = entry.zone.name
        if not grouped.beats[beat]
          grouped.beats[beat] = {}
        if not grouped.beats[beat][zoneid]
          grouped.beats[beat][zoneid] = {}
        grouped.beats[beat][zoneid][entry.type || "total"] = entry.qty
      # sort zones by name
      zonesSorted = []
      angular.forEach grouped.zones, (name, id)->
        zonesSorted.push {
          id: id
          name: name
        }
      grouped.zones = zonesSorted.sort (a, b)->
        if a.name > b.name then 1 else -1
      # return
      grouped

    getDataGroupedByPeriod: (data)->
      # variables
      grouped =
        beats: {}
        periods: {}
      # group all data as hash
      data.forEach (entry) ->
        beatid = entry.beat.id
        periodid = entry.period.id
        if not grouped.periods[periodid]
          grouped.periods[periodid] = {}
        if not grouped.periods[periodid][beatid]
          grouped.periods[periodid][beatid] =
            title: helper.getDateGroup entry.beat.datestart
        grouped.periods[periodid][beatid][entry.type || "total"] = entry.qty
      # return
      grouped

    getDataGroupedByZone: (data)->
      # variables
      grouped =
        zones: {}
      # group all data as hash
      data.forEach (entry) ->
        beat = helper.getDateGroup entry.beat.datestart
        type = entry.type || "total"
        zoneid = entry.zone.id
        if not grouped.zones[zoneid]
          grouped.zones[zoneid] = {}
        if not grouped.zones[zoneid][beat]
          grouped.zones[zoneid][beat] = {}
        if not grouped.zones[zoneid][beat][type]
          grouped.zones[zoneid][beat][type] = 0
        grouped.zones[zoneid][beat][type] += entry.qty
      # return
      grouped

    isPromise: (object)->
      object.then

    updateBeat: (beat, period)->
      datefrom = helper.getDate beat.datestart
      dateto = helper.getDate beat.datefinish
      beat.name = "#{datefrom.time}-#{dateto.time}"

    updatePeriod: (period)->
      datefrom = helper.getDate period.datestart
      dateto = helper.getDate period.datefinish

      if datefrom.date == dateto.date
        name = "#{datefrom.date} #{datefrom.time}-#{dateto.time}"
      else
        name = "#{datefrom.date} #{datefrom.time}-#{datefrom.date} #{dateto.time}"
      name = "#{name} - #{period.zone.name}"
      period.name = name

    updateStudy: (study, project)->
      name = project.name + ' - ' if project.name
      name += if study.occ_dur then 'Duration' else 'Occupancy'
      name += ' study '
      name += if study.beats_ee then '(entry/exit)' else '(beats)'
      #name += " [#{study.id}]"
      study.name = name

      if not study.groupby
        study.groupby = []

        total =
          "title": "Total"
          "type": "total"
          "types": null
        study.groupby.push total

        if study.bay_angle
          groupby =
            "title": "Bay Angle"
            "type": "bayangle"
            "types": []
          study.bay_angle.split '/'
          .forEach (type)->
            groupby.types.push
              name: type.toLowerCase()
              selected: true
              title: type
          study.groupby.push groupby

        if study.bay_type
          groupby =
            "title": "Bay Types"
            "type": "baytype"
            "types": []
          study.bay_type.split '/'
          .forEach (type)->
            groupby.types.push
              name: type.toLowerCase()
              selected: true
              title: type
          study.groupby.push groupby

        if study.beats_ee
          groupby =
            "title": "Entry/Exit"
            "type": "entryexit"
            "types": []
          'In/Out'.split '/'
          .forEach (type)->
            groupby.types.push
              name: type.toLowerCase()
              selected: true
              title: type
          study.groupby.push groupby

        if study.legal_illegal
          groupby =
            "title": "Legal/Illegal"
            "type": "legal"
            "types": []
          "Legal/Illegal".split '/'
          .forEach (type)->
            groupby.types.push
              name: type.toLowerCase()
              selected: true
              title: type
          study.groupby.push groupby

        if study.occupied
          groupby =
            "title": "Occupied"
            "type": "occupied"
            "types": []
          "Occupied/Unoccupied".split '/'
          .forEach (type)->
            groupby.types.push
              name: type.toLowerCase()
              selected: true
              title: type
          study.groupby.push groupby

        if study.vehicle_classification
          groupby =
            "title": "Vehicle Types"
            "type": "vehicle"
            "types": []
          study.vehicle_classification.split '/'
          .forEach (type)->
            groupby.types.push
              name: type.toLowerCase()
              selected: true
              title: type
          study.groupby.push groupby





  class Chart

    constructor: () ->
      # set filters to be independent for each instance
      #@filters = angular.merge {}, @filters # deep copy in angular > 1.4
      filters = {}
      angular.forEach @filters, (filter, name)->
        filters[name] = angular.extend {}, filter
      @filters = filters

    # all available filters
    filters:
      beat:
        required: true
        #submit: 'id'
        visible: true
      customer:
        require: true
        #submit: 'id'
        visible: true
      datefrom:
        required: true
        submit: true
        visible: true
      dateto:
        required: true
        submit: true
        visible: true
      groupby:
        multi: true
        required: true
        submit: 'type'
        visible: true
      period:
        required: true
        #submit: 'id'
        visible: true
      project:
        required: true
        #submit: 'id'
        visible: true
      report: # report type
        required: true
        visible: true
      study:
        required: true
        submit: 'id'
        visible: true
      zone:
        required: true
        submit: 'id'
        visible: true

    getChartOptions: ()->
      # return
      options =
        percents:
          title: "Percents"
          selected: false

    getExportData: ()->
      chartData = @getChartData()
      exportData = []
      ignore = []

      # titles
      row = []
      chartData[0].forEach (cell, i)->
        if angular.isObject cell
          ignore[i-1] = true
        else
          row.push cell
      exportData.push row

      # data
      chartData[1..].forEach (chartRow, i)->
        row = []
        chartRow.forEach (cell, c)->
          if not ignore[c]
            row.push cell
        exportData.push row

      # return
      exportData

    getGoogleChart: (element)->
      new google.visualization.ColumnChart element

    getGoogleChartOptions: ()->
      options =
        #title: @getTitle()
        vAxis:
          minValue: 0
      if @selected.options and @selected.options.percents and @selected.options.percents.selected
        options.vAxis.format = '#.##%'
      options

    getFilters: ()->
      @filters

    getReportType: ()->
      @selected.report.type

    getSelectedOptions: ()->
      options = {
        annotate: true
      }
      if @selected.options
        angular.forEach @selected.options, (option, name)->
          options[name] = option.selected
      # return
      options

    getSubmitData: ()->
      data = {}
      angular.forEach @filters, (filter, name)=>
        if filter and filter.submit and @selected[name]
          value = if filter.submit is true then @selected[name] else @selected[name][filter.submit]
          data[name] = value
      # return
      data

    getTitle: ()->
      title = @selected.study.name
      if @filters.beat.visible and @selected.beat
        title += ": #{@selected.beat.name}"
      if @filters.groupby.visible and @selected.groupby and @selected.groupby.types
        groupby = []
        @selected.groupby.types.forEach (type)->
          if type.selected
            groupby.push type.title
        if groupby.length
          title += ": " + groupby.join " vs "
      title

    init: (selected)->

      @previous = {} # previously selected values
      @selected = selected # save selected to local object

      # set global options
      @selected.options = @getChartOptions()

      # set report type
      @filters.report.options = [{"id": @_reportType, "type": @_reportType}] if not @filters.report.options
      @filters.report.visible = false if @filters.report.options.length == 1

      # try to set report selected in previous chart
      @previous.report = @selected.report if @selected.report
      @_setFilterOptions 'report', @filters.report.options, @filters.report.options[0]

      true

    setCustomer: (customer)->
      if @filters.project
        @filters.project.options = null
        @selected.project = null
        if customer
          if customer.projects
            @_setFilterOptions 'project', @_getProjects customer.projects
          else
            @filters.project.options = Data.getProjectsWithCountries()
            .then (projects)=>
              customer.projects = angular.copy projects
              if @selected.customer and @selected.customer.projects
                @_setFilterOptions 'project', @_getProjects @selected.customer.projects
      true

    setData: (data)->
      @_reportData = data

    setPeriod: (period)->
      if @filters.beat
        @filters.beat.options = null
        @selected.beat = null
        if period
          if period.beats
            @_setFilterOptions 'beat', @_getBeats period.beats
          else
            @filters.beat.options = Beat.getByField 'periodid', [period.id], false, true
            .then (beats)=>
              period.beats = angular.copy beats
              period.beats.forEach (beat, i)->
                helper.updateBeat beat, period
              if @selected.period and @selected.period.beats
                @_setFilterOptions 'beat', @_getBeats @selected.period.beats
      true

    setProject: (project)->
      if @filters.study
        @filters.study.options = null
        @selected.study = null
        if project
          if project.studies
            @_setFilterOptions 'study', @_getStudies project.studies
          else
            @filters.study.options = Study.getByField 'projectid', [project.id], false, true
            .then (studies)=>
              project.studies = angular.copy studies
              project.studies.forEach (study, i)->
                helper.updateStudy study, project
              if @selected.project and @selected.project.studies
                @_setFilterOptions 'study', @_getStudies @selected.project.studies
      if @filters.zone
        @filters.zone.options = null
        @selected.zone = null
        if project
          if project.zones
            @_setFilterOptions 'zone', @_getZones project.zones
          else
            @filters.zone.options = Data.getProjectZones project.id
            .then (zones)=>
              project.zones = angular.copy zones
              if @selected.project and @selected.project.zones
                @_setFilterOptions 'zone', @_getZones @selected.project.zones
      true

    setReport: (report)->
      # @previous = {}
      angular.forEach @selected, (value, name)=>
        if @filters[name] and name not in ['report']
          @previous[name] = value # save previously selected value
          @selected[name] = null # reset selected filter

      if @filters.customer
        @filters.customer.options = [{}] if not @filters.customer.options
        @filters.customer.visible = false if @filters.customer.options.length == 1
        customers = @_getCustomers @filters.customer.options
        @_setFilterOptions 'customer', customers, customers[0] or null
      true

    setStudy: (study)->
      if @filters.groupby
        @filters.groupby.options = null
        @selected.groupby = null
        if study
          @_setFilterOptions 'groupby', study.groupby

      if @filters.period
        @filters.period.options = null
        @selected.period = null
        if study
          if study.periods
            @_setFilterOptions 'period', @_getPeriods study.periods
          else
            @filters.period.options = Data.getStudyPeriods study.id
            .then (periods)=>
              study.periods = angular.copy periods
              study.periods.forEach (period, i)->
                helper.updatePeriod period
              if @selected.study and @selected.study.periods
                @_setFilterOptions 'period', @_getPeriods @selected.study.periods
      true

    setZone: (zone)->
      if @filters.period
        @filters.period.options = null
        @selected.period = null
        if @selected.study and @selected.study.periods
          @_setFilterOptions 'period', @_getPeriods @selected.study.periods
      true

    _getBeats: (beats)-> beats
    _getCustomers: (customers)-> customers
    _getPeriods: (periods)-> periods
    _getProjects: (projects)-> projects
    _getStudies: (studies)-> studies
    _getZones: (zones)-> zones

    _reportData = null
    _reportType: "zonebybeat"

    _setFilterOptions: (name, options, defaultOption)->
      @filters[name].options = options
      value = null # set selected value

      if @previous[name]
        if @filters[name].options
          if @previous[name].id
            value = helper.getById @previous[name].id, @filters[name].options
          else
            value = @previous[name] if @filters[name].options.indexOf @previous[name] > -1
        else
          value = @previous[name]

      value = defaultOption if not value # set default value if value is empty
      @selected[name] = value

      # call setProperty method to update values
      func = "set" + name.charAt(0).toUpperCase() + name.slice 1
      if this[func]
        this[func] value
      true





  class ChartColumn extends Chart
    title: "Column"
    image: "/assets/images/chart-column.png"

    init: ()->
      # update filters
      @filters.datefrom.visible = false
      @filters.dateto.visible = false
      @filters.period.required = false
      @filters.report.options = [
          "id": "beat"
          "name": "Statistic for beat"
          "type": "zonebybeat"
        ,
          "id": "zone"
          "name": "Statistic for zone"
          "type": "beatbyzone"
      ]
      super

    getChartData: ()->

      data = @_reportData
      options = @getSelectedOptions()
      selected = @selected
      types = (selected.groupby.types or [{"name":"total","selected":true,"title":"Amount"}]).filter (type)-> type.selected

      if @selected.report.id == 'zone'
        if @selected.period
          data = helper.getDataGroupedByPeriod data
          data = data.periods[@selected.period.id] or {}
        else
          data = helper.getDataByBeats data

        # set column keys/titles
        chartData = [["Beat"]]
        types.forEach (type)->
          chartData[0].push if options.percents then "#{type.title} %" else type.title
          if options.annotate
            chartData[0].push {"role":"annotation"}

        total = 0
        angular.forEach data, (beat, id)->
          total++
          chartEntry = [beat.title]
          types.forEach (type)->
            qty = beat[type.name] or 0
            chartEntry.push qty
            if options.annotate
              chartEntry.push qty
          chartData.push chartEntry

        if not total
          throw new Error "There is no statistic for selected period(s)"

      else
        data = helper.getDataGroupedByBeat data

        if not data.beats[helper.getDateGroup selected.beat.datestart]
          throw new Error "There is no statistic for selected beat"

        # set column keys/titles
        chartData = [["Zone"]]
        types.forEach (type)->
          chartData[0].push if options.percents then "#{type.title} %" else type.title
          if options.annotate
            chartData[0].push {"role":"annotation"}

        # chart data
        beat = data.beats[helper.getDateGroup selected.beat.datestart]
        data.zones.forEach (zone)->
          chartEntry = [zone.name]
          types.forEach (type)->
            qty = beat[zone.id] and beat[zone.id][type.name] or 0
            chartEntry.push qty
            if options.annotate
              chartEntry.push qty
          chartData.push chartEntry

      if options.percents
        chartData[1..].forEach (row)->
          ignore = (index)-> (index is 0) or (options.annotate and index % 2 == 0)
          total = 0
          row.forEach (value, index)->
            if not ignore index
              total += value
          if total > 0
            row.forEach (value, index)->
              if not ignore index
                row[index] = parseFloat (value / total).toFixed 2
                if options.annotate
                  row[index + 1] = "#{parseInt row[index] * 100}%"
      # return
      chartData

    setReport: (report)->
      if report
        if report.id == 'zone'
          @filters.beat.visible = false
          @filters.zone.visible = true
        else
          @filters.beat.visible = true
          @filters.zone.visible = false
      super

    _getPeriods: (periods)->
      if @filters.zone.visible
        zoneid = @selected.zone and @selected.zone.id or null
        if zoneid
          periods = periods.filter (period)->
            period.zoneid == zoneid
        else
          periods = null
      # return
      periods





  class ChartBar extends ChartColumn
    title: "Bar"
    image: "/assets/images/chart-bar.png"

    getGoogleChartOptions: ()->
      angular.extend {}, super(), {isStacked:true}





  class ChartCombo extends Chart
    title: "Combo"
    image: "/assets/images/chart-combo.png"

    init: ()->
      # update filters
      @filters.beat.visible = false
      @filters.datefrom.visible = false
      @filters.dateto.visible = false
      @filters.zone.visible = false
      super

    getChartData: ()->

      data = @_reportData
      options = @getSelectedOptions()
      selected = @selected
      types = (selected.groupby.types or [{"name":"total","selected":true,"title":"Amount"}]).filter (type)-> type.selected

      if @selected.period
        data = helper.getDataGroupedByPeriod data
        data = data.periods[@selected.period.id] or {}
      else
        data = helper.getDataByBeats data

      # set column keys/titles
      chartData = [["Beat"]]
      types.forEach (type)->
        chartData[0].push if options.percents then "#{type.title} %" else type.title
        if options.annotate
          chartData[0].push {"role":"annotation"}
      if options.averagebytype
        types.forEach (type)->
          chartData[0].push if options.percents then "Average #{type.title} %" else "Average #{type.title}"
      if options.average
        chartData[0].push 'Average'
      if options.total
        chartData[0].push 'Total'

      totalentries = 0
      totalsbybeat = []
      totalsbytype = {}

      angular.forEach data, (beat, id)->
        chartEntry = [beat.title]
        types.forEach (type)->
          qty = beat[type.name] or 0
          chartEntry.push qty
          if options.annotate
            chartEntry.push qty
          # collect total per beat for all types
          totalsbybeat[totalentries] = (totalsbybeat[totalentries] or 0) + qty
          # collect total per type for all beats
          totalsbytype[type.name] = (totalsbytype[type.name] or 0) + qty
        # collect number of chart entries
        totalentries++
        chartData.push chartEntry

      if not totalentries
        throw new Error "There is no statistic for selected period(s)"

      if options.percents
        chartData[1..].forEach (row)->
          ignore = (index)-> (index is 0) or (options.annotate and index % 2 == 0)
          total = 0
          row.forEach (value, index)->
            if not ignore index
              total += value
          if total > 0
            row.forEach (value, index)->
              if not ignore index
                row[index] = parseFloat (value / total).toFixed 2
                if options.annotate
                  row[index + 1] = "#{parseInt row[index] * 100}%"

      if options.averagebytype
        angular.forEach totalsbytype, (total, type)->
          totalsbytype[type] = parseFloat (total / totalentries).toFixed 2
        chartData[1..].forEach (row)->
          types.forEach (type)->
            row.push totalsbytype[type.name]

      if options.average
        chartData[1..].forEach (row, index)->
          row.push parseFloat (totalsbybeat[index] / types.length).toFixed 2

      if options.total
        chartData[1..].forEach (row, index)->
          row.push totalsbybeat[index]

      # return
      chartData

    getChartOptions: ()->
      # return
      options =
        average:
          title: "Average"
          selected: false
        averagebytype:
          title: "Average by type"
          selected: false
        total:
          title: "Total"
          selected: false

    getGoogleChart: (element)->
      new google.visualization.ComboChart element

    getGoogleChartOptions: ()->

      options = @getSelectedOptions()
      types = (@selected.groupby.types or [{"name":"total","selected":true,"title":"Amount"}]).filter (type)-> type.selected

      from = types.length
      to = types.length

      to = (to + types.length) if options.averagebytype
      to = (to + 1) if options.average
      to = (to + 1) if options.total

      series = {}
      for row in [from..to]
        series[row] = {type: "line"}

      angular.extend {}, super(), {
        seriesType: 'bars'
        series: series
      }

    getSubmitData: ()->
      angular.extend super, {
        "zone":@selected.period.zoneid
      }

    _reportType: "beatbyzone"





  class ChartGeo extends Chart
    title: "Geo"
    image: "/assets/images/chart-geo.png"

    init: ()->
      # update filters
      @filters.beat.required = false
      @filters.datefrom.visible = false
      @filters.dateto.visible = false
      @filters.report.options = [
          "id": "summary"
          "name": "Period/Beat Summary"
          "type": "zonebybeat"
        ,
          "id": "accuracy"
          "name": "Beat Accuracy (%)"
          "type": "beataccuracybyzone"
        ,
          "id": "comments"
          "name": "Most Sent Comments"
          "type": "commentbyzone"
      ]
      @filters.zone.visible = false
      super

    getChartData: (isExport)->

      data = helper.getDataGroupedByZone @_reportData
      options = @getSelectedOptions()
      types = [{"name":"total","title":"Amount"}]
      zones = []

      if @filters.groupby.visible and @selected.groupby and @selected.groupby.types
        types = @selected.groupby.types.filter (type)-> type.selected

      @selected.project.zones.forEach (zone)->
        coordinates = angular.fromJson zone.map
        if coordinates and coordinates[0]
          zones.push
            id: zone.id
            latlng: coordinates[0]
            name: zone.name

      if not zones.length
        throw new Error "There are no zones with coordinates to show"

      zones.forEach (zone)->
        zone.beats = data.zones[zone.id] or null

      # filters by date/time
      datefrom = '0000-00-00'
      dateto = '9999-99-99'
      if @filters.period.visible and @selected.period
        datefrom = helper.getDateGroup @selected.period.datestart
        dateto = helper.getDateGroup @selected.period.datefinish
      if @filters.beat.visible and @selected.beat
        datefrom = helper.getDateGroup @selected.beat.datestart
        dateto = helper.getDateGroup @selected.beat.datestart

      zones.forEach (zone)->
        qty = 0
        totalBeats = 0
        angular.forEach zone.beats, (beat, date)->
          if date >= datefrom and date <= dateto
            totalBeats++
            types.forEach (type)->
              qty += beat[type.name] or 0
        zone.beats = totalBeats
        zone.qty = qty

      if options.hideempty
        zones = zones.filter (zone)-> zone.beats > 0

      if zones.length == 0
        throw new Error "There are no zones with statistic to show"

      # set column keys/titles
      if isExport
        chartData = [['Zone', 'Value']]
      else
        chartData = new google.visualization.DataTable
        chartData.addColumn 'number', 'Lat'
        chartData.addColumn 'number', 'Long'
        chartData.addColumn 'string', 'Zone'
        chartData.addColumn 'number', 'Value'
        #chartData.addColumn {type:'string', role:'tooltip'}

      getLabel = (zone)->
        zone.qty
      getValue = (zone)->
        zone.qty
      switch @selected.report.id
        when "accuracy"
          getLabel = (zone)->
            qty = getValue zone
            "#{qty * 100}%"
          getValue = (zone)->
            if zone.beats > 0
              zone.qty = parseFloat (zone.qty / zone.beats).toFixed 2 # success (%)
            else
              zone.qty = 1
            zone.qty

      zones.forEach (zone)->
        if isExport
          chartEntry = [
            zone.name
            getLabel zone
          ]
          chartData.push chartEntry
        else
          chartEntry = [
            zone.latlng.lat
            zone.latlng.lng
            zone.name
            getValue zone
          ]
          chartData.addRow chartEntry

      # return
      chartData

    getChartOptions: ()->
      # return
      options =
        hideempty:
          title: 'Hide Empty'
          selected: true

    getExportData: ()->
      @getChartData true

    getGoogleChart: (element)->
      new google.visualization.GeoChart element

    getGoogleChartOptions: ()->
      options =
        displayMode: 'markers'
        region: 'world'

      if @selected.options.country and @selected.options.country.selected
        options.region = @selected.project.country.code or options.region

      switch @selected.report.id
        when "accuracy"
          angular.extend options, {
            colorAxis:
              colors: ['#FF0000','#FF3333','#FF9999','green']
              minValue: 0
              maxValue: 1
            legend:
              numberFormat: '#.##%'
            sizeAxis:
              minSize: 6
              maxSize: 6
          }
        else
          data = @getChartData true
          maxValue = 0
          data[1..].forEach (row)->
            if row[1] > maxValue
              maxValue = row[1]
          angular.extend options, {
            colorAxis:
              colors: ['blue','yellow','red']
              minValue: 0
            sizeAxis:
              minValue: 0
              maxValue: maxValue
          }
      # return
      options

    getTitle: ()->
      title = "#{@selected.report.name}: #{@selected.study.name}"
      if @selected.beat
        title += ": #{@selected.beat.name}"
      if @selected.groupby and @selected.groupby.types
        groupby = []
        @selected.groupby.types.forEach (type)->
          if type.selected
            groupby.push type.title
        if groupby.length
          title += ": " + groupby.join " + "
      title

    setProject: (project)->
      super project
      # load zones for project
      if project
        if not project.zones and not @filters.zone
          Data.getProjectZones project.id
          .then (zones)->
            project.zones = angular.copy zones

      # show Country option if available in project
      if project and project.country and project.country.code
        if not @selected.options.country
          @selected.options.country =
            title: "Country Map"
            selected: true
      else
        delete @selected.options.country

    setReport: (report)->
      if report
        @filters.beat.visible = true
        @filters.groupby.visible = true
        @filters.period.required = true
        switch report.id
          when 'accuracy'
            @filters.beat.visible = false
            @filters.groupby.visible = false
            @filters.period.required = false
          when 'comments'
            @filters.groupby.visible = false
            @filters.period.required = false
      super





  class ChartLine extends Chart
    title: "Line"
    image: "/assets/images/chart-line.png"

    init: ()->
      @filters.beat.visible = false
      @filters.datefrom.visible = false
      @filters.dateto.visible = false
      @filters.period.visible = false
      @filters.zone.visible = false
      super

    getChartData: ()->

      data = helper.getDataGroupedByBeat @_reportData
      options = @getSelectedOptions()
      selected = @selected
      types = (selected.groupby.types or [{"name":"total","selected":true,"title":"Amount"}]).filter (type)-> type.selected

      # set column keys/titles
      chartData = [["Beat"]]
      data.zones.forEach (zone)->
        chartData[0].push if options.percents then "#{zone.name} %" else zone.name
        if options.annotate
          chartData[0].push {"role":"annotation"}

      # chart data
      angular.forEach data.beats, (beat, beatid)->
        chartEntry = [beatid]
        data.zones.forEach (zone)->
          qty = 0
          types.forEach (type)->
            if type.selected
              qty += beat[zone.id] and beat[zone.id][type.name] or 0
          chartEntry.push qty
          if options.annotate
            chartEntry.push qty
        chartData.push chartEntry

      if options.percents
        chartData[1..].forEach (row)->
          ignore = (index)-> (index is 0) or (options.annotate and index % 2 == 0)
          total = 0
          row.forEach (value, index)->
            if not ignore index
              total += value
          if total > 0
            row.forEach (value, index)->
              if not ignore index
                row[index] = parseFloat (value / total).toFixed 2
                if options.annotate
                  row[index + 1] = "#{parseInt row[index] * 100}%"
      # return
      chartData

    getGoogleChart: (element)->
      new google.visualization.LineChart element

    getGoogleChartOptions: ()->
      angular.extend {}, super(), {
        pointSize: 3
      }

    getTitle: ()->
      title = @selected.study.name
      groupby = []
      angular.forEach @selected.groupby.types, (type)->
        if type.selected
          groupby.push type.title
      if groupby.length
        title += ": " + groupby.join ' + '
      title





  toReturn = ()-> this
  toReturn.prototype.getCharts = ()-> [new ChartLine, new ChartColumn, new ChartGeo, new ChartCombo, new ChartBar]
  new toReturn()
