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
    @ppeView = new dashboard.PPEView config.promised_ppe_data
    @sapiView = new dashboard.SAPIView config.promised_sapi_data
  
  render: ->
    @$el.append @ppeView.$el


dashboard.PPEView = Backbone.View.extend

  el: '#ppe'
  template: _.template( $('#ppe-template').html() )

  initialize: (promised_data) ->
    promised_data.then(
      (data) => @render data,
      (err) -> console.log err
    )

  render: (data) ->
    template = Handlebars.compile( $("#ppe-template").html() )
    @$el.html( template({data: data, title: 'Protected Planet Data:'}) )


dashboard.SAPIView = Backbone.View.extend

  el: '#sapi'
  template: _.template( $('#sapi-template').html() )

  initialize: (promised_data) ->
    promised_data.then(
      (data) => @render data,
      (err) -> console.log err
    )

  render: (data) ->
    template = Handlebars.compile( $("#sapi-template").html() )
    @$el.html( template({data: data, title: 'SAPI Data:'}) )