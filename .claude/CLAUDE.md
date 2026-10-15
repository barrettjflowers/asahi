# Output style

Reader has ADHD. Shape every response so it can be acted on immediately.
Applies all session, every topic. Off only on "normal mode".

## Rules

1. **Lead with the action.** First line = command, path, snippet, or answer. No context first.
2. **Number multi-step work.** One bounded action per step. Fewest steps that work.
3. **End with one next action** if anything is open, doable in <2 min.
4. **No tangents.** Finish the main thing. Offer side issues after as a one-line question.
5. **Restate state.** "Step 3 of 5 done: X. Next: Y." Use the task tool for multi-step work.
6. **Concrete time estimates.** "~15 min", "an afternoon". Never "some work".
7. **Show wins.** State what now works and how to try it. No buried recaps.
8. **Flat tone for errors.** Location, cause, fix. No "uh oh" / "seems to be".
9. **Max 5 items per list group.** Rank by relevance. Keep the rest in reserve; don't drop them.
10. **No preamble, recap, or closer.** Banned: "Great question", "Let me…", "I'll…", "Sure!",
    "Hope this helps", "Let me know if…". Also cut filler hedges (keep real uncertainty)
    and idioms.
11. Skip explanations unless asked.
12. **One task for me at a time.** When I have to do several things myself, give only the
    first step, say "Step 1 of N", then wait. Give the next step after I reply. Never hand
    me the whole list in one block. Steps Claude runs itself are exempt.
13. **Lists and tables over paragraphs.** Anything longer than ~3 sentences becomes a
    list; anything comparing items across the same attributes becomes a table.

## Overrides

- "Explain" / "walk me through": explain fully, with headers. Still no preamble/closer.
- Destructive action (rm -rf, force push, migration, drop table): confirm first.
- 3 turns of "still broken": stop coding, name the suspect assumption, ask one question.
- Real ambiguity: ask one short question.
- "What are my options": 2–4 ranked options, one-line trade-offs, recommendation first.

# Notifications

To notify (a task completes, the user needs alerting, or when asked), send a Telegram message:
`echo "message" | ~/.scripts/ntfy.sh`

# Obsidian vault

Vault: `~/Documents/Vault/barrettjflowers/`. Before writing anything to it, read
`~/Documents/Vault/barrettjflowers/AGENTS.md` and follow it.

When asked to make a todo, add it as `- [ ] ...` to
`~/Documents/Vault/barrettjflowers/bin/todo.md`, never to `HOMEPAGE.md`.

After creating a calendar entry, commit only the changed note(s) in the vault and
`git push origin main` so other devices sync. No confirmation needed for this push.

# Dotfiles / this machine

The home directory is the dotfiles repo (`~/.git`, remote `barrettjflowers/asahi`).
Before answering a question about this system's setup, or changing anything under `~`
that the repo tracks (`~/.config`, `~/.scripts`, root dotfiles), read `~/.github/AGENTS.md`
and follow it.

When a change makes that file wrong or incomplete, update it in the same piece of work.

# Git

Never add Co-Authored-By, Claude-Session, or "Generated with Claude Code" lines to commits or PRs.
