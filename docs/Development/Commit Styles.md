
# Commit Notes

Follow this format for commit notes:

- lower case
- follow `<type>(<scope?>): <description>` format
- `: ` after prefix, before description


**Use the following prefixes**

- `build` - Affect build-related components such as build tools, dependencies, project version, CI/CD pipelines, or trigger builds
- `chore` - Miscellaneous commits e.g. modifying .gitignore, removing files, etc
- `docs` - Commits that exclusively affect documentation
	- Note: use `docs(idea):` for contributions to the brainstorming folder
- **`feat`** - Commits that introduce, adjust, or remove a feature in the codebase
- **`fix`** - Commits that resolve bugs
- **`init`** - Commits which solely add new files
- `refactor` - Commits that rewrite or restructure code without altering codebase behavior
	- Replaces `cleanup`
- `perf` - specifically improve performance
- `style` - e.g., white-space, formatting, missing semi-colons - should **not affect application behavior**
- `test` - missing tests or modify existing ones, or are used for debugging
- `wip` - a checkpoint/sync commit, with the understanding that a series of wip: commits will eventually lead to a feat: or a fix:

Modellers:

You're most likely using either `init` or `feat`, maybe `fix`.

- `init: car model and textures`
- `feat: export latest vampire model`
- `fix: flipped normals`
