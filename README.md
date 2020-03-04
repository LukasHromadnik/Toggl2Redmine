# Toggl2Redmine

> ⚠️ Currently under development! Use at your own risk!

Swift script that automatically transfers time entries from Toggl to Redmine.

## Prerequisities

You have to obtain your access tokens for Redmine and Toggl. Then create a file at `~/.t2r/credentials.json` with the following content
```
{
    "redmine": "{YOUR-REDMINE-TOKEN}",
    "toggl": "{YOUR-TOGGL-TOKEN}"
}
```

## Instalation and usage

You can copy the binary to some directory in your `$PATH`, then you can run the application from Terminal.

If you are not a fan of Terminal, just copy the binary to some place where it'll be easy to find. If you want to use it, just double-click it.

## Time entry format

In order for the script to recognise that the time entry should be sychronized, the title of the time entry has to start with the following format:

`#{redmine-issue-id}:`

After that it can be whatever text you want. The letter is not used within the synchronization.

Optionally you can specify a comment for the Redmine entry. Use `[comment]` to add `comment` to the entry.

By default the script clusters multiple entries per day and per Redmine task. As a result only one entry will be created in the Redmine. This entry has sum of durations of all appropriate Toggl's entries. Also all comments in those entries are joined.

## Synchronization

The script uses tag with the name `Synchronized` to distinguish which time entries were synchronized and which weren't.
