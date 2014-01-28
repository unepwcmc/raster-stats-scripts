# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

dashboard = {}

$.support.cors = true

# http://stackoverflow.com/a/7515161/1932827
_.templateSettings = {
  interpolate: /\{\{\=(.+?)\}\}/g,
  evaluate: /\{\{(.+?)\}\}/g
};

$(document).ready( ->

  applicatin_config =
    ppe_api_url: 'http://localhost:3500/api2/countries'
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
        @fetchData application_config.ppe_api_url, application_config.country
      )

  app: ->
    view = new dashboard.AppView @config
    
  fetchData: (url, country) ->
    $.ajax(
      type: 'GET'
      dataType: 'json'
      url: url
      data: {iso: country}
      xhrFields:
        withCredentials: true
    )


dashboard.AppView = Backbone.View.extend

  el: '#app'

  initialize: (config) ->
    @ppeView = new dashboard.PPEView config.promised_ppe_data
  
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
    # Compile the template using Handlebars
    template = Handlebars.compile( $("#ppe-template").html() )
    # Load the compiled HTML into the Backbone "el"
    @$el.html( template({data: data, title: 'Protected Planet Data:'}) )