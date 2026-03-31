# macOS HTTP Distribution for Windows Remote MCP Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Run BGG MCP in a Docker container on macOS using Streamable HTTP, and let a Windows machine connect to that server over MCP HTTP.

**Architecture:** macOS hosts the Dockerized BGG MCP service and exposes the MCP endpoint over a stable HTTP port. Windows does not run the server locally; it connects as a remote MCP client to the macOS host URL using a client configuration that supports Streamable HTTP. Environment values stay on the macOS side and are injected into the container at startup.

**Tech Stack:** Go 1.23+ service, Docker, MCP Streamable HTTP transport, JSON client config for Windows, shell/PowerShell launch and verification scripts.

---

## Status Ledger

Track execution state here. `executing-plans` updates this section in place.

Task | Status | Facts
--- | --- | ---
Task 1: Container HTTP runtime | completed | `docker compose -f docker-compose.macos-http.yml up -d --build` started the container in `http` mode; `curl -fsS http://localhost:8080/.well-known/mcp-config` returned the schema; `docker compose ... ps` showed port 8080 published
Task 2: Windows remote client config | completed | `windows-mcp-remote.json` uses `transport: streamable-http` with a remote URL and does not reference `docker` or local stdio execution
Task 3: Configuration and secrets wiring | completed | `setup-env.sh` now writes both `.env` and `docker-compose.macos-http.env`; `.env.example` points to the macOS HTTP host flow; `docker-compose.macos-http.env.example` captures host-side runtime inputs
Task 4: End-to-end verification | completed | HTTP `initialize`, `tools/list`, and `tools/call` all succeeded over `/mcp`; with the real host env loaded from `.env`, `bgg-hot` returned live BGG hotness data over the remote HTTP path

## Design Traceability Matrix

Design Clause ID | Criticality | Mapped Tasks | Verification Command | Artifact Evidence Field | Failure Signal
--- | --- | --- | --- | --- | ---
DC-01 | critical | Task 1 | `docker compose -f docker-compose.macos-http.yml up -d && curl -fsS http://localhost:8080/.well-known/mcp-config` | `compose logs:service_started` | endpoint is unreachable or container starts in stdio mode
DC-02 | critical | Task 3 | `docker compose -f docker-compose.macos-http.yml config` | `runtime env:BGG_API_KEY, BGG_COOKIE, BGG_USERNAME` | secrets are baked into the image or missing from container env
DC-03 | critical | Task 2 | `cat windows-mcp-remote.json` and client import check on Windows | `windows config:url` | Windows config still uses `docker run` or local command execution
DC-04 | critical | Task 4 | `curl -fsS http://<mac-host>:8080/mcp` plus one real MCP tool invocation from Windows client | `mcp call result:tool_name` | only health/config endpoints work, but tool calls fail
DC-05 | critical | Task 4 | `docker logs <container>` during Windows connection attempt | `tool evidence:server logs + tool output` | fake connectivity with no server-side tool execution

## Plan

### Task 1: macOS container HTTP runtime

**User Verification: required**

**Files:**
- Modify: `Dockerfile`
- Create: `docker-compose.macos-http.yml`
- Modify: `README.md`
- Modify: `server.json`

**Step 1: Write the launch shape**

Define the container as a first-class HTTP server entrypoint for macOS use. The compose file must publish the MCP port, pass the BGG environment variables through, and set the process to `-mode http`.

**Step 2: Keep image build generic**

Preserve the existing image build so it can still be used for stdio, but make the HTTP runtime path explicit in the macOS distribution docs and compose file.

**Step 3: Add a failing launch check**

Run: `docker compose -f docker-compose.macos-http.yml up -d`

Expected: container starts, but the verification must fail until the compose file explicitly passes `-mode http` and the published port matches the docs.

**Step 4: Verify the HTTP endpoint**

Run: `curl -fsS http://localhost:8080/.well-known/mcp-config`

Expected: JSON schema response describing `BGG_API_KEY`, `BGG_COOKIE`, and `BGG_USERNAME`.

**Step 5: Commit**

Run:

```bash
git add Dockerfile docker-compose.macos-http.yml README.md server.json
git commit -m "feat: add macos http runtime for remote mcp"
```

### Task 2: Windows remote client config

**User Verification: required**

**Files:**
- Create: `windows-mcp-remote.json`
- Modify: `QUICK_START.md`
- Modify: `README.md`

**Step 1: Write the remote config**

Create a Windows MCP config that points to the macOS host URL and uses the remote MCP HTTP transport expected by the client. The config must not reference `docker`, a local binary, or `stdio`.

**Step 2: Add a placeholder rejection check**

Run a simple validation against the config file contents.

Run: `grep -n '"command": "docker"' windows-mcp-remote.json`

Expected: no matches. This is a negative check to reject a fake local-runtime config.

**Step 3: Add client-specific instructions**

Document the exact Windows client path for import and the expected server URL format. Keep the text concrete so the user can paste the config without rewriting the structure.

**Step 4: Verify the config is host-based**

Run: `grep -n '"http' windows-mcp-remote.json`

Expected: the config includes a remote HTTP URL or equivalent remote transport field, not a local command runner.

**Step 5: Commit**

Run:

```bash
git add windows-mcp-remote.json QUICK_START.md README.md
git commit -m "feat: add windows remote mcp client config"
```

### Task 3: Configuration and secrets wiring

**User Verification: not-required**

**Files:**
- Modify: `.env.example`
- Modify: `setup-env.sh`
- Create: `docker-compose.macos-http.env.example`
- Modify: `README.md`

**Step 1: Define host-side env input**

Document that the macOS host owns the actual credentials and injects them into the container with `environment:` or an env file. Do not copy secrets into image layers.

**Step 2: Add a secrets placement check**

Run: `grep -R "bggpassword=\\|SessionID=\\|your_api_key_here" -n .`

Expected: matches should only exist in examples and docs, never in runtime config or committed secret files.

**Step 3: Add container env example**

Provide an env file example that shows the required variables and their expected shape, but keeps values empty or clearly marked as host-local inputs.

**Step 4: Verify env handoff**

Run: `docker compose -f docker-compose.macos-http.yml config`

Expected: rendered compose output shows env injection without embedding literal private values in the image definition.

**Step 5: Commit**

Run:

```bash
git add .env.example setup-env.sh docker-compose.macos-http.env.example README.md
git commit -m "docs: clarify macos host-side secret injection"
```

### Task 4: End-to-end verification

**User Verification: required**

**Files:**
- Modify: `README.md`
- Modify: `QUICK_START.md`
- Modify: `TEST_REPORT.md` if a reusable verification record is desired

**Step 1: Start the macOS service**

Run the compose stack on the macOS host and confirm the HTTP endpoint is listening.

**Step 2: Connect from Windows**

Import the Windows remote config and point it at the macOS host URL on the LAN or VPN address.

**Step 3: Execute a real tool call**

Use one known tool, such as `bgg-search` or `bgg-hot`, from the Windows MCP client.

Expected: the tool returns BGG data, not a transport error or a fallback local stub.

**Step 4: Add a negative authenticity check**

Run a control test with the macOS container stopped.

Expected: the Windows client fails to connect, which proves the earlier success was a live remote connection and not cached or local-only behavior.

**Step 5: Record evidence**

Capture:
- container logs showing HTTP server startup
- endpoint response from `/.well-known/mcp-config`
- Windows client tool output
- one failed control case with the container stopped

**Step 6: Commit**

Run:

```bash
git add README.md QUICK_START.md TEST_REPORT.md
git commit -m "docs: document end-to-end macos http remote mcp verification"
```

## Plan Audit Verdict
audit_scope: [macOS HTTP runtime, Windows remote client config, host-side secret injection, end-to-end remote tool execution]
finding_summary: P0=0, P1=0, P2=1
critical_mismatches:
- none
major_risks:
- Windows client transport support varies by app status: accepted
anti_placeholder_checks:
- remote Windows config rejects `docker run` and local stdio command execution
- runtime env checks reject baked-in credential values
authenticity_checks:
- tool-level MCP invocation required over HTTP
- stopped-container control case required to prove live remote connectivity
approval_decision: pass
