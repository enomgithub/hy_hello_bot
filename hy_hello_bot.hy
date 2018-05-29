#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import asyncio)
(import os)
(import sys)

(import discord)


(setv *client* ((. discord Client)))


(with-decorator *client*.event
  (defn/a on-ready []
    (print "Logged in as")
    (print (. *client* user name))
    (print (. *client* user id))
    (print "-----")))


(with-decorator *client*.event
  (defn/a on-message [message]
    (cond [((. message content startswith) "!test")
           (setv counter 0)
           (setv tmp (await ((. *client* send-message)
                             (. message channel)
                             "Calculating messages...")))
           (for/a [log ((. *client* logs-from) (. message channel) :limit 100)]
                  (when (= (. log author) (. message author))
                        (setv counter (inc counter))))
           (await ((. *client* edit-message)
                   tmp
                   ((. "You have {} messages." format) counter)))]
          [((. message content startswith) "!sleep")
           (await ((. asyncio sleep) 5))
           (await ((. *client* send-message)
                   (. message channel)
                   "Done sleeping"))]
          [((. message content startswith) "hi")
           (if-not (= (. *client* user) (. message author))
                   (await ((. *client* send-message)
                           (. message channel)
                           (+ "hy, " (. message author name) "!"))))])))


(defn main[]
  ((. *client* run) (. os environ ["DISCORD_TOKEN"]))
  0)


(when (= --name-- "__main__")
      ((. sys exit) (main)))
