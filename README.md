# hubot-stagehand

## Hubot Stagehand

### Description:
   Stagehand manages who is currently using your team's staging server.

### Dependencies:
   None

### Configuration:
   None

### Commands:
  `stagehand who [env]` - Show who has booked the staging server and how much time they have left
  `stagehand book [env] [minutes]` - Book the staging server and optionally specify usage time. Default is 30min
  `stagehand cancel [env]` - Cancel the current booking. Defaults to cancel staging.
  `stagehand list` - List all environments and their status
  `stagehand add [env]` - Add an environment
  `stagehand remove [env]` - Remove an environment
  `stagehand help` - Display available commands

### Author:
   tinifni / nelsonenzo /nrevko

1. Edit `package.json` and add `hubot-stagehand` to the `dependencies` section. It should look something like this:

        "dependencies": {
          "hubot-stagehand": ">= 0.1.0",
          ...
        }
1. Add "hubot-stagehand" to your `external-scripts.json`. It should look something like this:

    ["hubot-stagehand"]
