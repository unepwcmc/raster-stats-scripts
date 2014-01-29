# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

dashboard = {}
$.support.cors = true

$(document).ready( ->
  applicatin_config =
    ppe_api_url: 'http://localhost:3500/api2/countries'
    sapi_api_url: 'http://localhost:3600/api/v1/stats'
    country: 'GB' #tmp
  router = new dashboard.Router applicatin_config
  Backbone.history.start()
)

dashboard.Router = Backbone.Router.extend

  routes:
    '': 'app'

  initialize: (application_config) ->
    @config = 
      promised_ppe_data: $.when(
        @fetchData application_config.ppe_api_url, application_config.country, yes
      )
      promised_sapi_data: $.when(
        @fetchData application_config.sapi_api_url, application_config.country
      )
      country: application_config.country

  app: ->
    view = new dashboard.AppView @config
    
  fetchData: (url, country, query_param) ->
    data = if query_param then {iso: country} else null
    url = if query_param then url else url + "/#{country}"
    $.ajax(
      type: 'GET'
      dataType: 'json'
      url: url
      data: data
      xhrFields:
        withCredentials: true
    )


dashboard.AppView = Backbone.View.extend

  el: '#app'

  initialize: (config) ->
    @ppeView = new dashboard.PPEView config.promised_ppe_data, config.country
    @sapiView = new dashboard.SAPIView config.promised_sapi_data, config.country
  
  render: ->
    @$el.append @ppeView.$el


dashboard.PPEView = Backbone.View.extend

  el: '#ppe'
  template: _.template( $('#ppe-template').html() )

  initialize: (promised_data, country) ->
    promised_data.then(
      (data) => @render data, country
      (err) -> console.log err
    )

  render: (data, country) ->
    template = Handlebars.compile( $("#ppe-template").html() )
    @$el.html( template({
      data: data
      title: 'Protected Planet Data:'
      country: country
    }) )


dashboard.SAPIView = Backbone.View.extend

  el: '#sapi'
  template: _.template( $('#sapi-template').html() )

  initialize: (promised_data, country) ->
    promised_data.then(
      (data) => @render data, country
      (err) -> console.log err
    )

  render: (data, country) ->
    template = Handlebars.compile( $("#sapi-template").html() )
    @$el.html( template({
      data: @getTopResults(data)
      title: 'SAPI Data:'
      country: country
    }) )

  getTopResults: (data, top) ->
    top ||= 5
    _.each(data.species_results, (results, taxonomy) ->
      sorted_results = _.sortBy(results, (o) -> o.count ).reverse()
      top_results = sorted_results[...top]
      other_results = sorted_results[top..]
      other_result = {name: "other", count: 0}
      _.each(other_results, (o) ->
        other_result.count += o.count
      )
      top_results.push other_result
      # return empty if no counts at all
      if top_results[0].count == 0 then top_results = []
      data.species_results[taxonomy] = top_results
    )
    data