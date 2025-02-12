# branch-manager

GitHub action to automatically copy content between repository branches. This action can be used to extract desired files from a branch, rename the files if needed, perform string replacements within the selected files, and finally push the selected and potentially modified files to a different branch. Intended for workflows that require synchronization of content between branches and allows for the modification of select content within files.

This is a _composite_ action and must be run on a Linux-based runner like `ubuntu-latest` or similar.

Developed and maintained by Research Technology (RT), Tufts Technology Services (TTS), Tufts University.

## Inputs

- `source-branch`

  - Branch to copy content from. Defaults to the triggering branch.
  - Default: `${{ github.ref_name }}`

- `destination-branch`

  - Branch to copy content to.
  - **Required.** _No default value._

- `clear-destination`

  - Whether to delete all files from the destination branch before copying. Must be set to `"true"` for deletion to occur. Other values ignored.
  - Default: `"false"`

- `remove-items`

  - Newline-delimited list of glob patterns to delete from the destination branch before copying. Ignored if destination branch set to be cleared.
  - Default: `""`

- `copy`

  - Newline-delimited list of `source|destination` arguments passed to `rsync` and executed using archive mode. Source and destination paths are relative to the repository root and will default to the repository root if not provided or left empty. Commands executed in order provided.
  - Default: `""`

- `replace`

  - Newline-delimited list of `find|replace|glob` arguments used to perform string replacement in the copied files. Commands are executed using `sed` in order provided and applied only to files matching the glob pattern. Omitting the glob pattern will apply the replacement to all files.
  - Default: `""`

- `commit-message`

  - Message to use when committing changes to the destination branch. Defaults to the SHA of the triggering commit.
  - Default: `${{ github.sha }}`

- `use-bot`

  - Whether to use the `github-actions[bot]` account to commit and push changes. Must be set to `"true"` for the bot to be used. Other values ignored. (Author of the last commit on the source branch used by default.)
  - Default: `"false"`

## Usage Example

```yml
name: mirror-content
on:
  push:
    branches:
      - main
jobs:
  mirror-to-binder:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - id: date
        run: |
          echo "date=$(date +'%Y-%m-%d')" >> $GITHUB_OUTPUT
      - uses: tuftsrt/branch-manager@v1
        with:
          destination-branch: binder
          clear-destination: "true"
          copy: |
            environment.yml|.binder/
            *.ipynb|
            data/sample.csv|data.csv
            docs/|docs
          replace: |
            data/sample.csv|data.csv|*.ipynb
            GH_ACTIONS_DATE|${{ steps.date.outputs.date }}
```

The sample workflow above creates a new branch that allows the interactive execution of data analysis notebooks online via [Binder](https://mybinder.org/) by accomplishing the following.

1. any preexisting content on the `binder` branch is cleared
2. `environment.yml` from the `main` branch is copied into a new directory `.binder` on the `binder` branch
3. all `ipynb` files from the root of the `main` branch are copied into the root of the `binder` branch
4. `sample.csv` from the `data` directory on `main` is copied to the root of `binder` and renamed to `data.csv`
5. everything from `docs` on the `main` branch is copied into a new directory `docs` on the `binder` branch
6. references to `"data/sample.csv"` in the `ipynb` files on the `binder` branch are replaced with `"data.csv"`
7. placeholder `"GH_ACTIONS_DATE"` in all files on the `binder` branch is replaced with the current date

## Advanced Usage

Copy commands are executed via `rsync` using archive mode (`-a`). Note that the behavior of `rsync`differs from `cp`, especially when using archive mode. Please refer to [`man rsync`](https://download.samba.org/pub/rsync/rsync) for examples and instructions on how to ensure files copy over as expected. Note that each `source|destination` input is processed as follows.

```bash
rsync -a "$SOURCE_REPO"/$source "$DESTINATION_REPO"/$destination
```
