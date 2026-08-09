# Ladderly — Agent Context File

> Load this file at the start of every session. It is the single source of truth for what this
> project is, what's built, what's next, and what must never change. Update the STATUS section
> as you complete work — everything else here is stable and should rarely change.

---

## PROJECT

**Name:** Ladderly
**Event:** iQOO × Reskilll TechQuest, Pune, 9 Aug 2026 — ~60 min build sprint, live demo on iQOO device
**What it is:** An AI tutor with an autonomous agent loop. User types or scans (OCR) a topic →
agent teaches at a 3-level ladder (5yo/teen/expert) → quizzes in free text → grades and pinpoints
the exact misconception → agent decides autonomously what to do next (re-teach, escalate,
advance, or end session) → session ends with YouTube video suggestions and related topics.
Presented with Duolingo-style gamification (XP, streak, hearts, progress bar).

**What makes it not a wrapper:** the agent decides its own next action from a fixed action set
based on accumulated state (the mastery map), not a fixed screen sequence the user clicks through.

**One-liner for judges:** "Type any topic — 'quantum computing' — and Ladderly teaches it at your
level, tests you, finds exactly where you're confused, fixes that, then hands you real videos to
go deeper. Built so someone like your dad can just type what he's curious about and actually
understand it."

---

## STACK

- **Language/UI:** Kotlin, Jetpack Compose (native Android — NOT Flutter, NOT XML views)
- **Local storage:** DataStore / SharedPreferences only — no database, no backend, no auth
- **OCR:** Google ML Kit Text Recognition v2 — on-device, offline, no API key
- **AI:** single LLM provider (event-issued API key), called via Retrofit/OkHttp
- **Video:** YouTube Data API v3 `search.list`, deep-link to YouTube app (no in-app player)
- **Animation:** Compose `animateFloatAsState` / `AnimatedVisibility`; Lottie only if time allows

---

## HARD RULES — never violate these regardless of what a task seems to ask for

1. **No backend, no database, no login/auth, no cloud sync.** Local state only.
2. **No in-app video player.** Deep-link out to YouTube, always.
3. **Every AI call must have a hardcoded fallback.** If the API call fails, times out, or returns
   unparseable JSON, fall back silently to pre-baked content. Never show a raw error to the user.
4. **Build the fallback path before wiring the live API call**, for every feature. The app must
   be demoable on hardcoded content alone at any point in the build.
5. **The agent decides the next action — the user never manually picks "next."** Any UI change
   that adds a manual "next step" button defeats the core differentiator. Don't add one.
6. **Gamification is a presentation layer over `GameState.kt`, fully decoupled from
   `AgentEngine.kt` and the mastery map.** Never let game-state logic leak into agent decision
   logic, and never let it block the core loop from working.
7. **One accent color + neutrals.** Do not introduce a second competing brand color.
8. If a feature isn't in the MUST/SHOULD list below, don't build it without updating this file first.

---

## FEATURE PRIORITY

### MUST HAVE (build first, in order)
1. Topic input (`TextField`) with language toggle
2. OCR ingestion (ML Kit) → populates topic field, user can edit before submit
3. Ladder generation → `{eli5, teen, expert}` via `LADDER_PROMPT`
4. Free-text quiz → graded via `GRADE_PROMPT`, returns `{correct, misconception}`
5. `AgentEngine` loop (see ARCHITECTURE below) driving what happens after every quiz answer
6. Local persistence of the mastery map

### SHOULD HAVE (only after MUST HAVE works end-to-end)
7. "Why should I care" hook line before the ladder (`HOOK_PROMPT`)
8. Hobby-based analogy escalation ("still confused?" button, `ANALOGY_PROMPT`)
9. YouTube video suggestions at session end (`VIDEO_QUERY_PROMPT` + `search.list`)
10. Curiosity trail — 2-3 related next topics (`NEXT_TOPICS_PROMPT`)
11. Language toggle wired through all prompts (English/Hindi)
12. XP + streak counter (top bar, persistent)
13. Hearts on quiz (3 lives, lose one per wrong answer)
14. Progress bar across session stages (Hook → Ladder → Quiz → Mastery)

### NICE TO HAVE (only if everything above is done with time left)
15. TTS narration of the ladder
16. Save/share session as text card
17. Celebration animation on mastery (confetti/checkmark)
18. Topic path/map screen (Duolingo-style node trail)

### NEVER BUILD
Login/accounts · cloud backend/database · in-app video player · social/multiplayer features

---

## ARCHITECTURE

```
app/
 ├─ ui/
 │   ├─ IngestScreen.kt       // topic text input + OCR button + language toggle + streak badge
 │   ├─ HookScreen.kt         // "why this matters" line + progress bar starts
 │   ├─ LadderScreen.kt       // rung explanation, "still confused?" button, progress bar fills
 │   ├─ QuizScreen.kt         // free-text answer, hearts, +XP toast, feedback state
 │   └─ SessionEndScreen.kt   // mastery recap, celebration, XP/streak update, video cards, next-topic chips
 ├─ agent/
 │   ├─ AgentEngine.kt        // core loop: mastery map + last result → next action
 │   ├─ ActionExecutor.kt     // maps action → screen navigation / API call
 │   └─ MasteryMap.kt         // Map<concept, "untested"|"shaky"|"solid">
 ├─ game/
 │   └─ GameState.kt          // XP, streak, hearts — fully decoupled from agent/mastery logic
 ├─ network/
 │   ├─ ApiClient.kt          // Retrofit/OkHttp, single LLM endpoint
 │   ├─ PromptBuilder.kt      // builds JSON-structured prompts per type
 │   ├─ YoutubeClient.kt      // search.list wrapper
 │   └─ FallbackData.kt       // hardcoded topics/ladders/quizzes/videos
 └─ data/
     └─ LocalStore.kt         // DataStore wrapper, no backend
```

### Agent action set
```
ACTIONS = {
  TEACH(concept, rung)
  ANALOGIZE(concept, hobby)
  QUIZ(concept)
  ADVANCE(next_concept)
  SUGGEST_VIDEOS(topic)
  SUGGEST_NEXT_TOPICS(topic)
  STOP(summary)
}
```
Loop: after every quiz answer → call `AGENT_DECIDE_PROMPT` with mastery map + last Q&A → get
`{action, concept, reason}` → `ActionExecutor` runs it → repeat until `STOP`. Surface `reason` in
UI as a small "why" chip — this is the visible proof of agentic behavior for judges.

### Prompt templates (strict JSON output only, always)
| Prompt | Input | Output |
|---|---|---|
| `LADDER_PROMPT` | topic, language | `{eli5, teen, expert}` |
| `HOOK_PROMPT` | topic | `{hook}` |
| `AGENT_DECIDE_PROMPT` | mastery map, last Q&A | `{action, concept, reason}` |
| `GRADE_PROMPT` | question, user answer | `{correct, misconception}` |
| `ANALOGY_PROMPT` | concept, hobby | `{analogy}` |
| `VIDEO_QUERY_PROMPT` | topic, rung | `{search_query}` |
| `NEXT_TOPICS_PROMPT` | topic | `{topics: [string, string, string]}` |

### OCR flow
`IngestScreen` "Scan notes" button → camera/gallery intent → `InputImage.fromBitmap` →
`TextRecognizer.process()` → populate (editable) topic field. Fully offline, no key needed.

### Fallback dataset
5 pre-baked topics (quantum computing, photosynthesis, supply and demand, how vaccines work, why
the sky is blue), each with: full ladder, 2 quiz Q&As with misconceptions, 2-3 known-good YouTube
video IDs. Triggers on any API timeout/error/parse failure. Must be indistinguishable from live
content in the UI.

---

## GAMIFICATION SPEC (Duolingo reference)

| Element | Spec |
|---|---|
| XP | +10 per correct quiz answer, +5 per rung cleared, shown as toast/pop |
| Streak | Persisted daily-use counter, top bar, flame-style icon |
| Hearts | 3 per quiz session, -1 per wrong answer |
| Progress bar | `LinearProgressIndicator` + `animateFloatAsState`, fills across Hook→Ladder→Quiz→Mastery |
| Celebration | On `STOP`/mastery — Lottie confetti if time allows, else scale-spring checkmark |
| Microcopy | Playful, never clinical — "Nice! You've got this." not "Correct." |
| Color | One bold accent + neutrals in Material 3 `ColorScheme`, no second competing color |

`GameState.kt` holds all of this as its own local state, updated by `ActionExecutor` as a
side-effect of agent actions — it does not feed back into agent decisions.

---

## TEAM

- **Person 1 (Android/Product):** screens, navigation, OCR, APK build, device install/testing
- **Person 2 (AI/Logic):** prompt templates, `AgentEngine`, `ApiClient`, `FallbackData`
- **Person 3 (UX/Demo):** `GameState`, YouTube integration, polish/empty/loading states, README, demo rehearsal

Git: feature branches per module, merge to `main` after each working chunk. Don't touch
`AgentEngine.kt` and a screen file in the same window without a merge check.

---

## BUILD ORDER (~60 min)

| Time | Task | Owner |
|---|---|---|
| 0–5 | Repo init, empty Compose activity, confirm APK builds + installs on iQOO immediately | P1 |
| 5–15 | `IngestScreen` incl. OCR button (offline, no API dependency) | P1 |
| 15–20 | `FallbackData.kt` written — unblocks everyone else | P2 |
| 20–30 | `LadderScreen` + `LADDER_PROMPT` live, fallback tested | P2 |
| 30–38 | `QuizScreen` + `GRADE_PROMPT` | P2 |
| 38–48 | `AgentEngine` loop + `AGENT_DECIDE_PROMPT`, action execution wired | P1+P2 |
| 40–48 | `SessionEndScreen` + YouTube card layout (parallel) | P3 |
| 48–52 | YouTube API + deep-link + fallback video IDs | P3 |
| 48–52 | `GameState.kt` — XP/streak/hearts, progress bar, streak badge (parallel) | P3 |
| 52–56 | Full APK build, install on iQOO, full run-through, no-internet test | All |
| 56–60 | Demo rehearsal (30s/60s/90s), confirm fallback works live | All |

**If time runs short, cut in this order:** topic path map → celebration animation → TTS →
curiosity trail → hearts/XP → analogy escalation. **Never cut:** ingest, ladder, quiz, agent loop,
fallback safety.

---

## DEMO SCRIPT (90s)

- **0–10s:** "My dad wants to understand quantum computing. Not a Wikipedia page, not a 40-minute video. Someone to actually teach him."
- **10–20s:** Open app, type or OCR-scan a topic.
- **20–60s:** Hook → ladder → quiz (hearts, +XP) → agent autonomously re-teaches the missed piece (point at "why" chip) → mastery → celebration + streak → videos appear.
- **60–75s:** "Not a chatbot wrapper — an agent loop deciding what to teach based on what you actually got wrong. Works fully offline via on-device OCR and a hardcoded fallback."
- **75–90s:** "Type what you're curious about, walk away actually understanding it."

---

## GITHUB README REQUIREMENTS

Name, pitch, problem/solution, feature list (MUST/SHOULD only), architecture diagram, tech stack,
setup instructions, screenshots, demo video/GIF, future scope. Strip API keys/secrets/debug code
before final commit.

---

## STATUS — update this section as you build. This is what the agent should check first.

- [ ] Repo initialized, APK builds and installs on iQOO
- [ ] IngestScreen (text input)
- [ ] OCR ingestion working offline
- [ ] FallbackData.kt written (5 topics)
- [ ] LadderScreen + live LADDER_PROMPT wired
- [ ] QuizScreen + GRADE_PROMPT wired
- [ ] AgentEngine loop working end-to-end
- [ ] SessionEndScreen + YouTube suggestions
- [ ] GameState.kt — XP/streak/hearts working
- [ ] Progress bar animating across stages
- [ ] Celebration animation (if time allows)
- [ ] Full device run-through, no-internet test passed
- [ ] README complete, secrets removed
- [ ] Demo rehearsed at 90s/60s/30s

**Current blocker / next task:** _(fill this in — this is the first thing an agent should read)_