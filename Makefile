.PHONY: install docker validate test clean

install:
	@./setup_full.sh

docker:
	@./setup_docker.sh

validate:
	@echo "==> Validating dotfile symlinks..."
	@for program in nvim zsh ssh git kitty tmux lazygit; do \
		if [ -d "$$program" ]; then \
			if ls -la ~ | grep -q "\->.*dotfiles/$$program"; then \
				echo "  ✓ $$program symlinked"; \
			else \
				echo "  ⚠ $$program not symlinked"; \
			fi \
		fi \
	done

test:
	@echo "==> Running shellcheck on setup scripts..."
	@shellcheck setup_full.sh setup_docker.sh

clean:
	@echo "==> Removing all dotfile symlinks..."
	@for program in nvim zsh ssh git kitty tmux lazygit supernote; do \
		if [ -d "$$program" ]; then \
			stow -v --target="$HOME" -D "$$program" 2>/dev/null || true; \
		fi \
	done
	@echo "Done. Original dotfiles (if any) are in backups/"
