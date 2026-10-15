.PHONY: install docker validate test clean

install:
	@./setup_full.sh

docker:
	@./setup_docker.sh

validate:
	@echo "==> Validating dotfile symlinks..."
	@for check in "~/.zshrc:zsh" "~/.tmux.conf:tmux" "~/.gitconfig:git" "~/.ssh/config:ssh" "~/.config/nvim:nvim" "~/.config/kitty:kitty" "~/.config/lazygit:lazygit"; do \
		target=$$(echo $$check | cut -d: -f1); \
		name=$$(echo $$check | cut -d: -f2); \
		if [ -L "$$target" ]; then \
			echo "  ✓ $$name ($$target)"; \
		elif [ -e "$$target" ]; then \
			echo "  ⚠ $$name ($$target exists but not symlinked)"; \
		else \
			echo "  ✗ $$name ($$target missing)"; \
		fi; \
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
