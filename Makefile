DIR = testdir
MALICIOUS_DIR = malicious_dir
INTERVAL = 5

.PHONY: all setup antivirus restore clean

all: setup

setup:
	mkdir -p $(DIR)
	mkdir -p $(MALICIOUS_DIR)


antivirus: setup
	chmod +x antivirusd.sh
	./antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)


restore: setup
	chmod +x restore.sh
	./restore.sh $(DIR) $(MALICIOUS_DIR)


clean:
	rm -f directory-info.last directory-info.new
