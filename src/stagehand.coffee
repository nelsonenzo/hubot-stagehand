# Description:
#   Stagehand manages who is currently using your team's staging server.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   stagehand who [env] - Show who has booked the staging server and how much time they have left
#   stagehand book [env] [minutes] - Book the staging server and optionally specify usage time. Default is 30min
#   stagehand cancel [env] - Cancel the current booking. Defaults to cancel staging.
#   stagehand list - List all environments and their status
#   stagehand add [env] - Add an environment
#   stagehand remove [env] - Remove an environment
#   stagehand help - Display available commands

# Author:
#   tinifni / nelsonenzo /nrevko

class Message
  constructor: (env, minutes) ->
    @env = env
    @minutes = minutes
  getEnv: ->
    if @env == undefined
      return 'staging'
    else
      return @env

  getMinutes: ->
    if @minutes == undefined
      return 30
    else
      return Number(@minutes)

bookEnv = (data, user, minutes) ->
  return false if data.user != user && new Date() < data.expires
  unless data.user == user && new Date() < data.expires
    data.user = user
    data.expires = new Date()
  data.expires = new Date(data.expires.getTime() + minutes * 1000 * 60)

listEnv = (data) ->
  environments = []
  for k,v of data
    environments.push k unless k == 'undefined'
  return environments

status = (env, data) ->
  return env + ' is free for use.' unless new Date() < data.expires
  data.user + ' has ' + env + ' booked for the next ' \
            + Math.ceil((data.expires - new Date())/(60*1000)) \
            + ' minutes.'

cancelBooking = (data) ->
  data.expires = new Date(0)

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.stagehand ||= {}
    for env in ['staging']
      do (env) ->
        robot.brain.data.stagehand[env] ||= { user: "initial", expires: new Date(0) }

  robot.respond /stagehand book\s?([A-Za-z0-9\.-]+)*\s?(\d+)*/i, (msg) ->
    message = new Message(msg.match[1], msg.match[2])
    env = message.getEnv()
    minutes = message.getMinutes()

    if robot.brain.data.stagehand[env]==undefined
      msg.send "Cannot book non-existent environment "+env+".\nPlease add environment to the list before booking it '@hubot stagehand add "+env+"'."
    else
      bookEnv(robot.brain.data.stagehand[env], msg.message.user.name, minutes)
      msg.send status(env, robot.brain.data.stagehand[env])

  robot.respond /stagehand who\s?([A-Za-z0-9\.-]+)*/i, (msg) ->
    message = new Message(msg.match[1])
    env = message.getEnv()

    if robot.brain.data.stagehand[env]==undefined
      msg.send "Environment "+env+" doesn't exist. Please check '@hubot stagehand list'."
    else
      msg.send status(env, robot.brain.data.stagehand[env])

  robot.respond /stagehand cancel\s?([A-Za-z0-9\.-]+)*/i, (msg) ->
    message = new Message(msg.match[1])
    env = message.getEnv()

    if robot.brain.data.stagehand[env]==undefined
      msg.send "Environment "+env+" doesn't exist. Please check '@hubot stagehand list'."
    else
      cancelBooking(robot.brain.data.stagehand[env])
      msg.send status(env, robot.brain.data.stagehand[env])

  robot.respond /stagehand list\s?([A-Za-z0-9\.-]+)*/i, (msg) ->
    for env in listEnv(robot.brain.data.stagehand)
      msg.send status(env, robot.brain.data.stagehand[env])

  robot.respond /stagehand add\s?([A-Za-z0-9\.-]+)*/i, (msg) ->
    env = msg.match[1]

    if env==undefined
      msg.send "Cannot add undefined environment"
    else if !(robot.brain.data.stagehand[env]==undefined)
        msg.send "Environment "+env+" is already in the existing list. Please check '@hubot stagehand list'."
    else
      message = new Message(env)
      robot.brain.data.stagehand[env] ||= { user: "initial", expires: new Date(0) }
      msg.send "Environment "+env+" was successfully added."

  robot.respond /stagehand remove\s?([A-Za-z0-9\.-]+)*/i, (msg) ->
    env = msg.match[1]

    if env==undefined || robot.brain.data.stagehand[env]==undefined
      msg.send "Cannot remove "+env+" environment. Please check '@hubot stagehand list'."
    else
      if Object.keys(robot.brain.data.stagehand).length == 1
        msg.send "Cannot remove last environment " + env
      else
        delete robot.brain.data.stagehand[env]
        msg.send "Environment "+env+" was successfully removed."

  robot.respond /stagehand help\s?/i, (msg) ->
    help_text = "\n#   stagehand who [env] - Show who has booked the staging server and how much time they have left\n" +
      "#   stagehand book [env] [minutes] - Book the staging server and optionally specify usage time. Default is 30min\n" +
      "#   stagehand cancel [env] - Cancel the current booking\n" +
      "#   stagehand list - List all environments and their status\n" +
      "#   stagehand add [env] - Add an environment\n" +
      "#   stagehand remove [env] - Remove an environment\n" +
      "#   stagehand help - Display available commands\n"
    msg.send help_text
