---
description: Create aiworkshop GitHub repository from ProjectGengar Step-16 branch
auto_execution_mode: 3
---

# Create aiworkshop GitHub Repository

This workflow creates a new GitHub repository called 'aiworkshop' and populates it with content from the ProjectGengar Step-16 branch using the GitHub MCP server.

## Prerequisites

- GitHub MCP server must be configured and authenticated
- Git must be installed and available in PATH
- Current repository must have a Step-16 branch

## Steps

### 1. Get GitHub username

First, we need to get your GitHub username to construct the repository URL.

Use the GitHub MCP server to get your username:
- Call `mcp3_get_me` to retrieve your GitHub user information
- Note the username from the response

### 2. Create the new repository

Create a new public repository called 'aiworkshop':
- Call `mcp3_create_repository` with:
  - `name`: "aiworkshop"
  - `description`: "AI Workshop - OpenEdge ABL Project"
  - `private`: false
  - `autoInit`: false

### 3. Checkout Step-16 branch

Switch to the Step-16 branch in the current repository:
```powershell
git checkout Step-16
```

If the branch doesn't exist locally, fetch it:
```powershell
git fetch origin Step-16:Step-16
git checkout Step-16
```

### 4. Collect all files from Step-16 branch

Read all files from the current directory and prepare them for upload in batches.

**Files to INCLUDE:**
- `.gitattributes`, `.gitignore`, `README.md`
- `openedge-project.json`, `build.xml`
- `src/**/*.cls` - All class files (CustomerEntity.cls, EntityFactory.cls)
- `src/**/*.i` - All include files (CustomerDataset.i)
- `src/**/*.w` - **ALL window files** (CustomerWin.w, ItemWin.w)
- `.windsurf/rules/*.md` - Windsurf rules
- `.windsurf/workflows/*.md` - Windsurf workflows
- `.github/ISSUE_TEMPLATE/*.md` - GitHub templates
- `dump/sports2000.df` - Database schema (first 500 lines)
- `doc/business-entity-pattern.md` - Documentation

**Files to EXCLUDE:**
- `.git/**` - Git repository data
- `builder.lock` - Builder lock file
- `db/**` - Database files (binary)
- `rcode/**` - Compiled code
- `conf/**` - Configuration files (environment-specific)
- `powershell/**` - PowerShell scripts
- `doc/corelib.json` - Large library documentation
- `doc/netlib.json` - Large library documentation
- `create-aiworkshop-repo.bat` - This workflow script itself
- Any other binary or generated files

Use `git ls-files` to get tracked files, then filter based on the above criteria.

### 5. Push all files to GitHub using MCP server

**IMPORTANT:** The repository must be initialized first with at least one file before batch pushing.

**Step 5.1 - Initialize repository:**
Create a README.md file first using `mcp3_create_or_update_file`:
- `owner`: username from step 1
- `repo`: "aiworkshop"
- `branch`: "main"
- `path`: "README.md"
- `message`: "Initial commit"
- `content`: Basic project description

**Step 5.2 - Push files in batches:**

Push files in batches to avoid size limits. Group files logically:

**Batch 1 - Core configuration:**
- `.gitattributes`, `.gitignore`, `openedge-project.json`, `build.xml`

**Batch 2 - Business logic:**
- All files in `src/business/` directory (`.cls` and `.i` files)

**Batch 3 - UI window files:**
- `src/CustomerWin.w` and `src/ItemWin.w`
- Read each .w file using `read_file` tool
- These are large files (10KB+) but can be pushed together in one batch

**Batch 4 - Windsurf rules:**
- All files in `.windsurf/rules/`

**Batch 5 - Windsurf workflows:**
- All files in `.windsurf/workflows/`

**Batch 6 - GitHub templates:**
- `.github/ISSUE_TEMPLATE/*.md`

**Batch 7 - Documentation:**
- Use `mcp3_create_or_update_file` for individual documentation files:
  - `doc/business-entity-pattern.md` (condensed version)
  - `dump/sports2000-schema.txt` (summary, not full .df file)

For each batch using `mcp3_push_files`:
- `owner`: username from step 1
- `repo`: "aiworkshop"
- `branch`: "main"
- `message`: Descriptive message for the batch
- `files`: array of file objects with path and content

**Performance Best Practices:**
1. Initialize repo with README first to create the main branch
2. Batch related files together (5-10 files per batch)
3. For very large files or documentation, use `mcp3_create_or_update_file` individually
4. Read files with `read_file` tool, not command-line tools
5. The .w files can be batched together despite their size

## Success

The repository 'aiworkshop' has been created and populated with content from the Step-16 branch.
You can view it at: `https://github.com/{username}/aiworkshop`

## Notes

- The GitHub MCP server handles both repository creation and file uploads
- No temporary directories or local git operations needed - everything is done via the MCP server
- The `mcp3_push_files` tool can handle multiple files in a single commit
- Files are read from the Step-16 branch and pushed directly to the new repository
- Error handling should be implemented at each step to ensure successful completion

## Performance Best Practices

**DO:**
- Push multiple files in a single `mcp3_push_files` call (batch approach)
- Group files logically (business logic, UI, configuration, etc.)
- Use `read_file` tool to read file contents
- Construct JSON arrays with multiple file objects
- Read large files (.w files) using `read_file` and manually construct the content string

**DON'T:**
- Push files one at a time (extremely slow)
- Use command-line tools like `type` or `Get-Content` for large files (they truncate)
- Make separate `mcp3_push_files` calls for each file
- Forget to escape special characters in file content (quotes, newlines)

## Example: Efficient Batch Push

```
// GOOD - Batch push (fast)
mcp3_push_files({
  owner: "username",
  repo: "aiworkshop",
  branch: "main",
  message: "Add UI windows",
  files: [
    {path: "src/CustomerWin.w", content: "...full content..."},
    {path: "src/ItemWin.w", content: "...full content..."}
  ]
})

// BAD - Individual pushes (slow)
mcp3_push_files({files: [{path: "src/CustomerWin.w", content: "..."}]})
mcp3_push_files({files: [{path: "src/ItemWin.w", content: "..."}]})
```
