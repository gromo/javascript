'use strict'

angular.module "i4Research"
.service "GoogleCharts", ($q) ->

  promise = null
  
  this.load = () ->
    if not promise
      promise = $q (resolve, reject) ->
        google.load "visualization", "1",
          callback: resolve
          packages:["bar","corechart","geochart"]
    promise
  
  this