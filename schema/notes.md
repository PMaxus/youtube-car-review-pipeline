# Data model notes

Process state lives in PostgreSQL. This is what makes the pipeline restart-safe and
auditable, and lets a human step in at any stage.

## Tables

| Table | Role |
|---|---|
| `sessions` | Telegram conversation state per user (menu, mode, current car, active job) |
| `jobs` | one review job per car request, with a status model |
| `job_videos` | confirmed source videos for a job: title/channel, transcript, per-video summary |
| `public.prompt_library` *(shared)* | agent prompts as data — **structure only**, texts not published |

## Job status model

```
searching ─▶ awaiting_confirmation ─▶ transcribing ─▶ summarizing ─▶ assembling ─▶ voicing ─▶ done
                     │                                                                         
                     └──────────────────────────── error (error_text) ◀───────────────────────
```

- **searching** — YouTube search by make/model.
- **awaiting_confirmation** — candidates shown in Telegram; the user confirms or rejects
  each source (human-in-the-loop). Only confirmed sources are written to `job_videos`.
- **transcribing** — transcripts pulled for confirmed videos.
- **summarizing** — each transcript summarized separately.
- **assembling** — per-video summaries merged into `jobs.total_summary`.
- **voicing** — final text turned into a sales voiceover.

## Human-in-the-loop

Source selection is the one step kept manual: the expensive steps (transcripts,
summarization, assembly, voiceover) start only after the user confirms the sources. This
cuts both the risk of building on bad sources and wasted token spend.

## Prompts as data

Agent prompts are stored in `public.prompt_library`, not inside AI nodes, so they can be
edited (versioned, deprecate-and-replace) without touching the workflows. A few agents
still carried inline prompts; those are redacted in this repository. The prompt texts are
not published.
