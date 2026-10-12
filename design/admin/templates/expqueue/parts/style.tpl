{* The look of Setup > Job queue. Scoped to .exp-queue-page; takes admin4's tokens (--a4-*) where they exist, with
   values of its own for the older admin designs. admin4's dark mode darkens only the frame around the white content
   card, so the page keeps its light palette there too (the chart colours are validated against that surface). *}
{literal}
<style>
.exp-queue-page {
    --q-ink: var(--a4-ink, #1f2430);
    --q-muted: var(--a4-muted, #5d6573);
    --q-line: var(--a4-line, #e3e6eb);
    --q-soft: var(--a4-soft, #f6f7f9);
    --q-card: var(--a4-card-bg, #fff);
    --q-accent: #c2410c;
    --q-accent-ink: #9a3412;
    --q-ring: rgba(194, 65, 12, 0.45);
    --q-ok: #166534;   --q-ok-bg: #e7f5ea;
    --q-warn: #8a4b00; --q-warn-bg: #fff3df;
    --q-bad: #b91c1c;  --q-bad-bg: #fdecec;
    --q-info: #1e4fa8; --q-info-bg: #e8effd;
    --q-done: #3b6fb6; --q-dead: #c43d3d;
    --q-radius: 12px;
    --q-mono: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    color: var(--q-ink);
    font-size: 14px;
    line-height: 1.5;
}
.exp-queue-page *, .exp-queue-page *::before, .exp-queue-page *::after { box-sizing: border-box; }
.exp-queue-page .box-content { padding-bottom: 20px; }
.exp-queue-page h1.context-title { margin: 0; overflow-wrap: anywhere; }
.exp-queue-page h2.q-h2 { margin: 0 0 10px; padding: 0; border: 0; background: none; font-size: 15px; font-weight: 650; color: var(--q-ink); display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.exp-queue-page h2.q-h2 .q-meta { font-weight: 400; }
.exp-queue-page p { margin: 0; }
.exp-queue-page code, .exp-queue-page .q-mono { font-family: var(--q-mono); font-size: 12.5px; overflow-wrap: anywhere; }
.exp-queue-page a { color: var(--q-accent-ink); }
.exp-queue-page a:hover { color: var(--q-ink); }
.exp-queue-page :focus-visible { outline: 3px solid var(--q-ring); outline-offset: 2px; }
.exp-queue-page .q-sr { position: absolute; width: 1px; height: 1px; margin: -1px; padding: 0; overflow: hidden; clip: rect(0 0 0 0); white-space: nowrap; border: 0; }
.exp-queue-page .q-meta { color: var(--q-muted); font-size: 13px; }
.exp-queue-page .q-section { margin: 0 0 18px; }

/* tabs and the status line */
.exp-queue-page .q-top { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 10px; margin: 0 0 14px; padding: 0 0 10px; border-bottom: 1px solid var(--q-line); }
.exp-queue-page .q-tabs { display: flex; flex-wrap: wrap; gap: 6px; margin: 0; padding: 0; list-style: none; }
.exp-queue-page .q-tabs li { margin: 0; }
.exp-queue-page .q-tabs a { display: inline-flex; align-items: center; min-height: 32px; padding: 3px 14px; border: 1px solid var(--q-line); border-radius: 999px; background: var(--q-card); color: var(--q-ink); font-size: 13.5px; font-weight: 600; text-decoration: none; }
.exp-queue-page .q-tabs a:hover { border-color: var(--q-accent); color: var(--q-accent-ink); }
.exp-queue-page .q-tabs a[aria-current="page"] { border-color: var(--q-accent); background: var(--q-accent); color: #fff; }
.exp-queue-page .q-status { display: inline-flex; align-items: center; gap: 8px; flex-wrap: wrap; font-size: 13px; color: var(--q-muted); }

/* messages */
.exp-queue-page .q-flash { margin: 0 0 14px; padding: 9px 14px; border: 1px solid var(--q-line); border-left: 4px solid var(--q-ok); border-radius: 10px; background: var(--q-ok-bg); color: var(--q-ok); overflow-wrap: anywhere; }
.exp-queue-page .q-flash.is-warn { border-left-color: var(--q-warn); background: var(--q-warn-bg); color: var(--q-warn); }
.exp-queue-page .q-flash.is-bad { border-left-color: var(--q-bad); background: var(--q-bad-bg); color: var(--q-bad); }
.exp-queue-page .q-flash.is-info { border-left-color: var(--q-info); background: var(--q-info-bg); color: var(--q-info); }

/* KPI strip */
.exp-queue-page .q-kpis { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 118px), 1fr)); gap: 8px; margin: 0 0 16px; padding: 0; list-style: none; }
.exp-queue-page .q-kpi { margin: 0; padding: 9px 12px; border: 1px solid var(--q-line); border-radius: var(--q-radius); background: var(--q-card); min-width: 0; }
.exp-queue-page .q-kpi a { color: inherit; text-decoration: none; display: block; }
.exp-queue-page .q-kpi strong { display: block; font-size: 22px; line-height: 1.15; font-weight: 700; font-variant-numeric: tabular-nums; color: var(--q-ink); }
.exp-queue-page .q-kpi span { font-size: 12.5px; color: var(--q-muted); }
.exp-queue-page .q-kpi.is-bad strong { color: var(--q-bad); }
.exp-queue-page .q-kpi.is-warn strong { color: var(--q-warn); }
.exp-queue-page .q-kpi.is-ok strong { color: var(--q-ok); }

/* cards and grid */
.exp-queue-page .q-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 380px), 1fr)); gap: 12px; margin: 0 0 16px; }
.exp-queue-page .q-card { min-width: 0; margin: 0; padding: 12px 14px; border: 1px solid var(--q-line); border-radius: var(--q-radius); background: var(--q-card); overflow-x: auto; }
.exp-queue-page .q-card.is-wide { grid-column: 1 / -1; }

/* the chart: jobs ended per hour, done and dead stacked */
.exp-queue-page .q-chart { display: grid; grid-template-columns: repeat(24, minmax(0, 1fr)); gap: 3px; align-items: end; height: 110px; margin: 6px 0 4px; padding: 0 0 0 0; border-bottom: 1px solid var(--q-line); }
.exp-queue-page .q-bar { position: relative; display: flex; flex-direction: column-reverse; gap: 2px; height: 100%; justify-content: flex-start; }
.exp-queue-page .q-bar .q-seg { display: block; width: 100%; min-height: 0; }
.exp-queue-page .q-bar .q-seg.is-done { background: var(--q-done); border-radius: 0 0 0 0; }
.exp-queue-page .q-bar .q-seg.is-dead { background: var(--q-dead); }
.exp-queue-page .q-bar .q-seg:last-child { border-top-left-radius: 4px; border-top-right-radius: 4px; }
.exp-queue-page .q-bar:hover .q-seg, .exp-queue-page .q-bar:focus .q-seg { filter: brightness(1.15); }
.exp-queue-page .q-bar .q-tip { display: none; position: absolute; bottom: calc(100% + 6px); left: 50%; transform: translateX(-50%); z-index: 2; padding: 5px 8px; border: 1px solid var(--q-line); border-radius: 8px; background: var(--q-card); color: var(--q-ink); font-size: 12px; white-space: nowrap; box-shadow: 0 6px 18px rgba(16,24,40,0.12); }
.exp-queue-page .q-bar:hover .q-tip, .exp-queue-page .q-bar:focus .q-tip { display: block; }
.exp-queue-page .q-axis { display: grid; grid-template-columns: repeat(24, minmax(0, 1fr)); gap: 3px; font-size: 11.5px; color: var(--q-muted); font-variant-numeric: tabular-nums; }
.exp-queue-page .q-axis span { text-align: center; }
.exp-queue-page .q-legend { display: flex; flex-wrap: wrap; gap: 4px 14px; margin: 6px 0 0; font-size: 12.5px; color: var(--q-muted); }
.exp-queue-page .q-legend i { display: inline-block; width: 10px; height: 10px; margin-right: 5px; border-radius: 3px; vertical-align: -1px; }
.exp-queue-page .q-legend .is-done i { background: var(--q-done); }
.exp-queue-page .q-legend .is-dead i { background: var(--q-dead); }
.exp-queue-page details.q-table-view { margin-top: 6px; font-size: 12.5px; }
.exp-queue-page details.q-table-view summary { cursor: pointer; color: var(--q-muted); }

/* compact tables */
.exp-queue-page table.q-table { width: 100%; border-collapse: collapse; font-size: 13px; font-variant-numeric: tabular-nums; }
.exp-queue-page table.q-table th { padding: 5px 8px; border-bottom: 1px solid var(--q-line); color: var(--q-muted); font-weight: 600; text-align: left; white-space: nowrap; background: none; }
.exp-queue-page table.q-table td { padding: 5px 8px; border-bottom: 1px solid var(--q-line); vertical-align: middle; overflow-wrap: anywhere; }
.exp-queue-page table.q-table tr:last-child td { border-bottom: 0; }
.exp-queue-page table.q-table td.q-num, .exp-queue-page table.q-table th.q-num { text-align: right; }
.exp-queue-page table.q-table tr.is-paused td { color: var(--q-muted); }
.exp-queue-page .q-scroll { overflow-x: auto; }
.exp-queue-page .q-empty { color: var(--q-muted); font-size: 13px; padding: 4px 0; }

/* badges */
.exp-queue-page .q-badge { display: inline-block; padding: 1px 8px; border-radius: 999px; font-size: 12px; font-weight: 600; white-space: nowrap; background: var(--q-soft); color: var(--q-muted); border: 1px solid var(--q-line); }
.exp-queue-page .q-badge.is-ready, .exp-queue-page .q-badge.is-active { background: var(--q-info-bg); color: var(--q-info); border-color: transparent; }
.exp-queue-page .q-badge.is-running { background: var(--q-warn-bg); color: var(--q-warn); border-color: transparent; }
.exp-queue-page .q-badge.is-done { background: var(--q-ok-bg); color: var(--q-ok); border-color: transparent; }
.exp-queue-page .q-badge.is-dead { background: var(--q-bad-bg); color: var(--q-bad); border-color: transparent; }
.exp-queue-page .q-badge.is-paused, .exp-queue-page .q-badge.is-held { background: var(--q-warn-bg); color: var(--q-warn); border-color: transparent; }

/* buttons (POST forms) */
.exp-queue-page form.q-inline { display: inline; margin: 0; }
.exp-queue-page .q-btn { display: inline-flex; align-items: center; min-height: 28px; padding: 2px 12px; border: 1px solid var(--q-line); border-radius: 999px; background: var(--q-card); color: var(--q-ink); font: inherit; font-size: 12.5px; font-weight: 600; cursor: pointer; white-space: nowrap; }
.exp-queue-page .q-btn:hover { border-color: var(--q-accent); color: var(--q-accent-ink); }
.exp-queue-page .q-btn.is-primary { background: var(--q-accent); border-color: var(--q-accent); color: #fff; }
.exp-queue-page .q-btn.is-primary:hover { background: var(--q-accent-ink); color: #fff; }
.exp-queue-page .q-btn.is-danger:hover { border-color: var(--q-bad); color: var(--q-bad); }
.exp-queue-page table.q-table td:has(> form.q-inline), .exp-queue-page table.q-table td:has(> .q-actions) { width: 1%; white-space: nowrap; }
.exp-queue-page table.q-table td code { overflow-wrap: normal; word-break: keep-all; }
.exp-queue-page .q-actions { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }

/* filters */
.exp-queue-page .q-filters { display: flex; flex-direction: column; gap: 6px; margin: 0 0 12px; }
.exp-queue-page .q-chips { display: flex; flex-wrap: wrap; gap: 5px; align-items: center; margin: 0; padding: 0; list-style: none; }
.exp-queue-page .q-chips li { margin: 0; }
.exp-queue-page .q-chips .q-label { font-size: 12.5px; color: var(--q-muted); margin-right: 4px; min-width: 52px; }
.exp-queue-page .q-chips a { display: inline-block; padding: 1px 10px; border: 1px solid var(--q-line); border-radius: 999px; font-size: 12.5px; text-decoration: none; color: var(--q-ink); background: var(--q-card); }
.exp-queue-page .q-chips a[aria-current="true"] { border-color: var(--q-accent); background: var(--q-accent); color: #fff; }
.exp-queue-page .q-chips a small { color: inherit; opacity: 0.75; }

/* facts */
.exp-queue-page dl.q-facts { display: grid; grid-template-columns: minmax(110px, max-content) minmax(0, 1fr); gap: 4px 14px; margin: 0; font-size: 13px; }
.exp-queue-page dl.q-facts dt { margin: 0; color: var(--q-muted); font-weight: 600; }
.exp-queue-page dl.q-facts dd { margin: 0; min-width: 0; overflow-wrap: anywhere; }

/* progress */
.exp-queue-page .q-progress { position: relative; height: 8px; border-radius: 999px; background: var(--q-soft); border: 1px solid var(--q-line); overflow: hidden; min-width: 80px; }
.exp-queue-page .q-progress span { position: absolute; inset: 0 auto 0 0; background: var(--q-done); border-radius: 999px; }
.exp-queue-page .q-pager { display: flex; gap: 8px; margin-top: 10px; }
@media (max-width: 640px) {
    .exp-queue-page .q-hide-narrow { display: none; }
    .exp-queue-page .q-axis span:nth-child(odd) { visibility: hidden; }
}
</style>
{/literal}
