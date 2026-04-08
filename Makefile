.PHONY: build install clean

BUILD_DIR := .build/release
BINARY := $(BUILD_DIR)/hhhz
INSTALL_DIR := $(HOME)/.local/bin

build:
	swift build -c release

install: build
	@mkdir -p $(INSTALL_DIR)
	@cp $(BINARY) $(INSTALL_DIR)/hhhz
	@chmod +x $(INSTALL_DIR)/hhhz
	@echo ""
	@$(INSTALL_DIR)/hhhz

clean:
	swift package clean
	rm -rf .build
