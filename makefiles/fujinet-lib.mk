FUJINET_LIB_VERSION := 4.8.0

# Use locally built fujinet-lib instead of downloading from GitHub
FUJINET_LIB_LOCAL_BUILD := /Users/dillera/code/fujinet-lib/build
FUJINET_LIB = $(CACHE_DIR)/fujinet-lib
FUJINET_LIB_VERSION_DIR = $(FUJINET_LIB)/$(FUJINET_LIB_VERSION)-$(CURRENT_TARGET)
FUJINET_LIB_PATH = $(FUJINET_LIB_VERSION_DIR)/fujinet-$(CURRENT_TARGET)-$(FUJINET_LIB_VERSION).lib
FUJINET_LIB_BASENAME := $(notdir $(FUJINET_LIB_PATH))
FUJINET_LIB_SYMLINK  := libfujinet-$(CURRENT_TARGET)-$(FUJINET_LIB_VERSION).lib.a

$(info CACHE_DIR = $(CACHE_DIR))
$(info Using locally built fujinet-lib from $(FUJINET_LIB_LOCAL_BUILD))

.get_fujinet_lib:
	@if [ ! -f "$(FUJINET_LIB_PATH)" ]; then \
		echo "Setting up fujinet-lib for $(CURRENT_TARGET) from local build"; \
		mkdir -p $(FUJINET_LIB_VERSION_DIR); \
		cp $(FUJINET_LIB_LOCAL_BUILD)/fujinet.lib.$(CURRENT_TARGET) $(FUJINET_LIB_PATH); \
		cp $(FUJINET_LIB_LOCAL_BUILD)/../fujinet-*.h $(FUJINET_LIB_VERSION_DIR)/ 2>/dev/null || true; \
		cp $(FUJINET_LIB_LOCAL_BUILD)/../fujinet-*.inc $(FUJINET_LIB_VERSION_DIR)/ 2>/dev/null || true; \
		echo "Copied $(FUJINET_LIB_PATH) and headers"; \
	fi; \
	if [ "$(CURRENT_TARGET)" == "coco" ]; then \
		( cd "$(FUJINET_LIB_VERSION_DIR)" && ln -sf "$(FUJINET_LIB_BASENAME)" "$(FUJINET_LIB_SYMLINK)" ); \
	fi

CFLAGS += -I$(FUJINET_LIB_VERSION_DIR)
ASFLAGS += --asm-include-dir $(FUJINET_LIB_VERSION_DIR)
LIBS += $(FUJINET_LIB_PATH)
ALL_TASKS += .get_fujinet_lib
