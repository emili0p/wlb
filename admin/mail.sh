#!/bin/bash
## this updates your mail and runs neomutt
mailsync
exec neomutt "$@"
