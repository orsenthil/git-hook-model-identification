# Model Identification Commit Specification

Status: draft. Keywords MUST/SHOULD/MAY follow RFC 2119.

## 1. Goal

Every commit made by an AI model carries a compact, machine-parseable
self-identification. A reviewer (typically a stronger model) uses it to know
who wrote the change and how sure the author model was.

## 2. Commit message format

One git trailer in the trailer block at the end of the message (separated from
the body by a blank line, parseable by `git interpret-trailers`):

```
Model: <model-id> harness=<tool> effort=<level> conf=<high|medium|low>
```

First token `<model-id>`: the exact API/model identifier the author knows
itself by (e.g. `claude-sonnet-5-5`). MUST NOT be a placeholder (`unknown`,
`n/a`, `none`, `ai`, `assistant`, `llm`, `<...>`) and MUST NOT contain `=`.

- Followed by space-separated `key=value` pairs; values contain no spaces or `=`:

| key | meaning | constraint |
|---|---|---|
| `harness` | tool the model ran in (`claude-code`, `codex-cli`, ...) | required |
| `effort` | reasoning effort or mode (`low`, `high`, `plan`, ...) | required |
| `conf` | author's confidence in the change | required; `high`, `medium` or `low` |

Example:

```
Add retry backoff to fetch

Model: claude-sonnet-5-5 harness=claude-code effort=high conf=medium
```

Deliberately omitted: date (git records it), and reviewer hints such as
focus/uncertainty/tests (belong in the commit body if wanted).

## 3. Enforcement (`commit-msg` hook)

1. Exempt (exit 0): `GIT_HUMAN_COMMIT=1`; merge in progress (`MERGE_HEAD`); subjects starting `Merge `, `Revert `

2. Otherwise parse trailers; if multiple `Model` trailers exist the last wins.

3. Validate 2. On any violation exit 1 and print to stderr: the required
   format, an example, and the specific problems. The stderr text is the
instruction to the model; it is expected to amend its message and retry.

## 4. Review records (`post-commit` hook)

- Copies the `Model` trailer plus `Review-Status: pending` into `git notes --ref=model-id` for `HEAD`.

- Commits without the trailer (exempt commits) get no note.

- The trailer is the source of truth. Notes are an index and MAY be lost on
amend/rebase or if not pushed (`git push origin refs/notes/*`).

## 5. Reviewer interface (`bin/model-review`)

- `list [range]`: prints `=== <sha> <subject>` followed by the note for each commit (default `HEAD` history).
- `comment <sha> <text>`: appends `<text>` to `refs/notes/model-review` for the commit, and rewrites its `model-id` note to `Review-Status: reviewed`.

## 6. Non-goals

Cryptographic proof of authorship (the identification is self-reported and can
be wrong or forged); blocking human commits; storing review comments in the
commit itself.

## 7. Versioning

Format changes bump the spec version. Adding optional keys is backward
compatible; hooks MUST ignore unknown keys.
