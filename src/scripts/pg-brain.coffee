# Description:
#   Stores the brain in Postgres
#
# Dependencies:
#   "pg": "^4.4.0"
#
# Configuration:
#   DATABASE_URL
#
# Commands:
#   None
#
# Notes:
#   Run the following SQL to setup the table and column for storage.
#
#   CREATE TABLE hubot (
#     id CHARACTER VARYING(1024) NOT NULL,
#     brain JSON NOT NULL,
#     CONSTRAINT hubot_pkey PRIMARY KEY (id)
#   )
#   INSERT INTO hubot VALUES(1, NULL)
#
# Author:
#   danthompson

Postgres = require 'pg'

# sets up hooks to persist the brain into postgres.
module.exports = (robot) ->

  database_url = process.env.DATABASE_URL

  if !database_url?
    throw new Error('pg-brain requires a DATABASE_URL to be set.')

  client = new Postgres.Client(database_url)
  client.connect()
  robot.logger.debug "pg-brain connected to #{database_url}."

  query = client.query("SELECT brain FROM hubot LIMIT 1")
  query.on 'row', (row) ->
    robot.brain.mergeData row.brain
    robot.logger.debug "pg-brain loaded."

  client.on "error", (err) ->
    robot.logger.error err

  robot.brain.on 'save', (data) ->
    query = client.query("UPDATE hubot SET brain = $1", [data])
    robot.logger.debug "pg-brain saved."

  robot.brain.on 'close', ->
    client.end()

