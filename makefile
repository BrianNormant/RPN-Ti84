# ----------------------------
# Makefile Options
# ----------------------------

NAME ?= RPN2ASM
DESCRIPTION ?= "Reverse Polish Notation"
COMPRESSED ?= NO
ARCHIVED ?= NO

CFLAGS ?= -Wall -Wextra -Oz
CXXFLAGS ?= -Wall -Wextra -Oz

# ----------------------------

include $(shell cedev-config --makefile)
