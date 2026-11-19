# Model Identification hook for Git Commits

It is desirable to have model and model properties identification in git
commits authored by AI models. This repository provides a git hook that
enforces a commit message format and a review workflow. 

Every AI-authored commit carries a one-line self-identification, so a stronger
model can review it later and know who wrote it and how sure they were.

A git hook can't instruct a model directly, so `commit-msg` **rejects the
commit with instructions**. The agent reads the error, adds the trailers, and
retries. It works with any agent that runs `git commit`.

## What a commit looks like

```
Add retry backoff to fetch

Model: claude-sonnet-5-5 harness=claude-code effort=high conf=medium
```

Full format and rules: [SPEC.md](SPEC.md).

## Install

```sh
cd your-repo && /path/to/install.sh     # this repo only (core.hooksPath -> this project's hooks/)
/path/to/install.sh --global            # all repos (copies hooks to ~/.config/git/hooks)
```

Global install copies the hooks, so re-run it after updating them. It also
overrides any per-repo `.git/hooks`.

## Use

- Agents: commit normally; if rejected, follow the printed instructions.

- Humans: `GIT_HUMAN_COMMIT=1 git commit ...` skips the check. Merges, reverts are exempt automatically

## Review workflow

`post-commit` copies the `Model` trailer into `git notes --ref=model-id` with `Review-Status: pending`.

```sh
bin/model-review list [range]            # self-ID + status per commit
bin/model-review comment <sha> "<text>"  # reviewer comment -> refs/notes/model-review; marks reviewed
git push origin refs/notes/model-id refs/notes/model-review   # notes are not pushed by default
```

The trailer in the commit message is the source of truth; notes are an index
and can be lost on amend/rebase.

## Limits

The identification is self-reported: a model can misstate its own ID or
confidence if it is instructed to do so.
