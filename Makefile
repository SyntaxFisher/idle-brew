# The only public target. MODE selects build, install, release, or publish.
MODE ?= install
export MODE
export SIGN_IDENTITY NOTARY_PROFILE NOTARY_CONFIG
.PHONY: install
install:
	python3 scripts/build.py
