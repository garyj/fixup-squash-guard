# fixup-squash-guard

A [pre-commit](https://pre-commit.com/) hook to prevent `fixup!` and `squash!` commits from being pushed to the remote
repository.

## Usage

This hook is used with: [pre-commit.com](https://pre-commit.com/).

### Setting Up `pre-commit` to Use This Hook

Add a reference to this repository in your project's `.pre-commit-config.yaml` file:

```yaml
repos:
  - repo: https://github.com/garyj/fixup-squash-guard
    rev: v0.2.0
    hooks:
      - id: check-commits
```

Install the pre-commit hook:

```bash
pre-commit install --hook-type pre-push
```

This command installs the pre-push hook in your local repository, ensuring it's run before each push to the remote
repository.

### Hook Behavior

- The hook checks all commits that are about to be pushed. If it finds any commit messages starting with `fixup!` or
  `squash!`, it aborts the push and outputs a warning message.
- To bypass the check temporarily, you can use the `--no-verify` option with `git push`.

## License

MIT
