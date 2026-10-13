.PHONY: install uninstall help backup

# Default target
help:
	@echo "Ultimate Labwc Rice - Make Targets"
	@echo ""
	@echo "  install   - Install rice configuration (backs up existing configs)"
	@echo "  uninstall - Remove installed symlinks"
	@echo "  backup    - Create backup of current configs"
	@echo "  help      - Show this help message"

# Install rice
install:
	@./install.sh

# Uninstall rice (remove symlinks only)
uninstall:
	@echo "=== Uninstalling Ultimate Labwc Rice ==="
	@echo "Removing symlinks..."
	@rm -f $(HOME)/.config/labwc $(HOME)/.config/waybar $(HOME)/.config/rofi
	@rm -f $(HOME)/.config/fuzzel $(HOME)/.config/swaylock $(HOME)/.config/wlogout
	@for script in $(wildcard scripts/*.sh); do \
		script_name=$$(basename $$script .sh); \
		rm -f $(HOME)/.local/bin/$$script_name; \
	done
	@echo "Uninstall complete. Config directories can be restored from backups."
	@echo "Backup locations: $(HOME)/.config.bak.*"

# Create backup
backup:
	@timestamp=$$(date +%Y%m%d_%H%M%S); \
	backup_dir=$(HOME)/.config.bak.$$timestamp; \
	echo "Creating backup in $$backup_dir"; \
	mkdir -p $$backup_dir; \
	for cfg in labwc waybar rofi fuzzel swaylock wlogout; do \
		if [ -e $(HOME)/.config/$$cfg ]; then \
			cp -r $(HOME)/.config/$$cfg $$backup_dir/ 2>/dev/null && echo "Backed up $$cfg"; \
		fi \
	done
