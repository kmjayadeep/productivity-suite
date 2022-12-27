# Productivity suite

Setup for my Productivity suite which includes

* notes -> Personal and work notes
* mindmap -> Similar to notes, but more ideal for random thoughts and ideas which are not organized
* todo -> Todo list

The idea is to have a client/server architecture along with a script, where

* server will keep the data as source of truth (in memory) and
  * do periodic backups (encrypted)
  * push to git periodically (encrypted)
  * expose a syncthing server for clients to sync
  * alerts for issues, out of sync errors, backup failures etc
* client script to
  * do the initial setup of sync, local folders etc
  * setup scripts to access notes, mindmap and todo from cli
  * enable offline editing

