all: lint format-check shaders-format-check

format-check:
	find -name '*.gd' | xargs gdformat --check

shaders-format-check:
	find -name '*.shader' | xargs clang-format --style=file --dry-run -Werror

lint:
	find -name '*.gd' | xargs gdlint
