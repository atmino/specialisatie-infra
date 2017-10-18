#minion_add:
#    wheel.key.accept:
#      - match: ['*minion*']

list_unaccepted:
    wheel.key.list
      - match: ['unaccepted']
