.PHONY: static base-up base-test base-down secure-up secure-test secure-down
static:
	python3 -m unittest discover -s tests -v
base-up:
	cd . && sudo bash scripts/start.sh
base-test:
	sudo bash scripts/verify.sh
base-down:
	sudo bash scripts/stop.sh
secure-up:
	cd secure && sudo bash scripts/deploy.sh
secure-test:
	cd secure && sudo bash scripts/verify.sh
secure-down:
	cd secure && sudo bash scripts/destroy.sh
