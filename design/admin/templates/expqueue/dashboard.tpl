{* expqueue/dashboard: the queue at a glance. A KPI strip, one chart (jobs ended per hour), and compact lists:
   classes, resources, workers, what runs, the dead letter, groups. Controls only for expqueue/manage. *}
{def $here = '/expqueue/dashboard'}
{set-block variable=$status}
{if $paused}{include uri='design:expqueue/parts/state.tpl' state='paused'}{else}{include uri='design:expqueue/parts/state.tpl' state='active'}{/if}
{if $can_manage}
{if $paused}
{if $paused_by_setting|not}{include uri='design:expqueue/parts/button.tpl' action='resume' scope='queue' name='' here=$here label='Resume queue'|i18n( 'extension/expqueue' ) kind='primary'}{/if}
{else}
{include uri='design:expqueue/parts/button.tpl' action='pause' scope='queue' name='' here=$here label='Pause queue'|i18n( 'extension/expqueue' ) confirm='Pause the whole queue? Running jobs finish; no new job starts.'|i18n( 'extension/expqueue' )}
{/if}
{include uri='design:expqueue/parts/button.tpl' action='test_job' here=$here label='Send a test job'|i18n( 'extension/expqueue' )}
{/if}
{/set-block}
{include uri='design:expqueue/parts/header.tpl' title='Job queue'|i18n( 'extension/expqueue' ) status=$status}

{if $paused_by_setting}
<p class="q-flash is-warn">{'The queue is paused by the setting expqueue.ini [QueueSettings] Paused=enabled.'|i18n( 'extension/expqueue' )}</p>
{/if}

<ul class="q-kpis" aria-label="{'Key figures'|i18n( 'extension/expqueue' )|wash}">
    <li class="q-kpi"><a href={'/expqueue/list/(state)/ready'|ezurl}><strong>{$states.ready}</strong><span>{'Ready'|i18n( 'extension/expqueue' )}</span></a></li>
    <li class="q-kpi{if gt( $states.running, 0 )} is-warn{/if}"><a href={'/expqueue/list/(state)/running'|ezurl}><strong>{$states.running}</strong><span>{'Running'|i18n( 'extension/expqueue' )}</span></a></li>
    <li class="q-kpi"><a href={'/expqueue/list/(state)/active'|ezurl}><strong>{sum( $states.queued, $states.retry, $states.held )}</strong><span>{'Waiting or retrying'|i18n( 'extension/expqueue' )}</span></a></li>
    <li class="q-kpi{if gt( $states.dead, 0 )} is-bad{/if}"><a href={'/expqueue/list/(state)/dead'|ezurl}><strong>{$states.dead}</strong><span>{'Dead letter'|i18n( 'extension/expqueue' )}</span></a></li>
    <li class="q-kpi is-ok"><strong>{$totals.done_hour}</strong><span>{'Done in the last hour'|i18n( 'extension/expqueue' )}</span></li>
    <li class="q-kpi"><strong>{$totals.oldest_label|wash}</strong><span>{'Oldest ready job'|i18n( 'extension/expqueue' )}</span></li>
    <li class="q-kpi{if eq( $totals.workers, 0 )}{if $cron.ok|not} is-bad{/if}{else} is-ok{/if}"><strong>{$totals.workers}</strong><span>{'Workers alive'|i18n( 'extension/expqueue' )}</span></li>
</ul>

<div class="q-grid">

<section class="q-card is-wide" aria-labelledby="q-chart-title">
<h2 class="q-h2" id="q-chart-title">{'Jobs ended per hour'|i18n( 'extension/expqueue' )} <span class="q-meta">{'last 24 hours: %done done, %dead dead'|i18n( 'extension/expqueue',, hash( '%done', $hourly_done, '%dead', $hourly_dead ) )}</span></h2>
{if eq( $hourly_max, 0 )}
<p class="q-empty">{'No job ended in the last 24 hours.'|i18n( 'extension/expqueue' )}</p>
{else}
<div class="q-chart" role="img" aria-label="{'Jobs ended per hour over the last 24 hours; the table below has the numbers.'|i18n( 'extension/expqueue' )|wash}">
{foreach $hourly as $h}
<div class="q-bar" tabindex="0">
<span class="q-seg is-done" style="height: {$h.done_pct}%"></span>{if gt( $h.dead, 0 )}<span class="q-seg is-dead" style="height: {$h.dead_pct}%"></span>{/if}
<span class="q-tip">{$h.label|wash}:00 · {'%n done'|i18n( 'extension/expqueue',, hash( '%n', $h.done ) )}{if gt( $h.dead, 0 )} · {'%n dead'|i18n( 'extension/expqueue',, hash( '%n', $h.dead ) )}{/if}</span>
</div>
{/foreach}
</div>
<div class="q-axis" aria-hidden="true">{foreach $hourly as $i => $h}<span>{if eq( mod( $i, 3 ), 0 )}{$h.label|wash}{/if}</span>{/foreach}</div>
<p class="q-legend"><span class="is-done"><i></i>{'done'|i18n( 'extension/expqueue/state' )}</span><span class="is-dead"><i></i>{'dead'|i18n( 'extension/expqueue/state' )}</span><span>{'peak %n per hour'|i18n( 'extension/expqueue',, hash( '%n', $hourly_max ) )}</span></p>
<details class="q-table-view"><summary>{'Show as a table'|i18n( 'extension/expqueue' )}</summary>
<table class="q-table"><thead><tr><th>{'Hour'|i18n( 'extension/expqueue' )}</th><th class="q-num">{'done'|i18n( 'extension/expqueue/state' )}</th><th class="q-num">{'dead'|i18n( 'extension/expqueue/state' )}</th></tr></thead>
<tbody>{foreach $hourly as $h}{if or( gt( $h.done, 0 ), gt( $h.dead, 0 ) )}<tr><td>{$h.label|wash}:00</td><td class="q-num">{$h.done}</td><td class="q-num">{$h.dead}</td></tr>{/if}{/foreach}</tbody></table>
</details>
{/if}
</section>

<section class="q-card is-wide" aria-labelledby="q-classes-title">
<h2 class="q-h2" id="q-classes-title">{'Priority classes'|i18n( 'extension/expqueue' )}</h2>
<div class="q-scroll">
<table class="q-table">
<thead><tr>
<th>{'Class'|i18n( 'extension/expqueue' )}</th>
<th class="q-num">{'Weight'|i18n( 'extension/expqueue' )}</th>
<th class="q-num">{'Ready'|i18n( 'extension/expqueue' )}</th>
<th class="q-num">{'Running'|i18n( 'extension/expqueue' )}</th>
<th class="q-num q-hide-narrow">{'Waiting'|i18n( 'extension/expqueue' )}</th>
<th class="q-num">{'Dead'|i18n( 'extension/expqueue' )}</th>
<th class="q-num">{'Oldest'|i18n( 'extension/expqueue' )}</th>
<th class="q-num q-hide-narrow">{'p95 wait (1 h)'|i18n( 'extension/expqueue' )}</th>
<th class="q-num q-hide-narrow">{'Done (1 h)'|i18n( 'extension/expqueue' )}</th>
{if $can_manage}<th><span class="q-sr">{'Controls'|i18n( 'extension/expqueue' )}</span></th>{/if}
</tr></thead>
<tbody>
{foreach $classes as $c}
<tr{if $c.paused} class="is-paused"{/if}>
<td><a href={concat( '/expqueue/list/(class)/', $c.name )|ezurl}>{$c.name|wash}</a>{if $c.reserved} <span class="q-meta">{'reserved'|i18n( 'extension/expqueue' )}</span>{/if}{if $c.paused} {include uri='design:expqueue/parts/state.tpl' state='paused'}{/if}</td>
<td class="q-num">{$c.weight}</td>
<td class="q-num">{$c.ready}</td>
<td class="q-num">{$c.running}{if gt( $c.max_running, 0 )}<span class="q-meta"> / {$c.max_running}</span>{/if}</td>
<td class="q-num q-hide-narrow">{$c.waiting}</td>
<td class="q-num">{if gt( $c.dead, 0 )}<a href={concat( '/expqueue/list/(state)/dead/(class)/', $c.name )|ezurl}>{$c.dead}</a>{else}0{/if}</td>
<td class="q-num">{$c.oldest_label|wash}</td>
<td class="q-num q-hide-narrow">{$c.p95_label|wash}</td>
<td class="q-num q-hide-narrow">{$c.done_hour}</td>
{if $can_manage}<td>{if $c.paused}{include uri='design:expqueue/parts/button.tpl' action='resume' scope='class' name=$c.name here=$here label='Resume'|i18n( 'extension/expqueue' )}{else}{include uri='design:expqueue/parts/button.tpl' action='pause' scope='class' name=$c.name here=$here label='Pause'|i18n( 'extension/expqueue' )}{/if}</td>{/if}
</tr>
{/foreach}
</tbody>
</table>
</div>
</section>

<section class="q-card is-wide" aria-labelledby="q-res-title">
<h2 class="q-h2" id="q-res-title">{'Resources'|i18n( 'extension/expqueue' )}</h2>
{if $resources|count|eq( 0 )}
<p class="q-empty">{'No job names a resource yet.'|i18n( 'extension/expqueue' )}</p>
{else}
<table class="q-table">
<thead><tr><th>{'Resource'|i18n( 'extension/expqueue' )}</th><th class="q-num">{'Running / limit'|i18n( 'extension/expqueue' )}</th><th class="q-num">{'Ready'|i18n( 'extension/expqueue' )}</th><th>{'State'|i18n( 'extension/expqueue' )}</th>{if $can_manage}<th><span class="q-sr">{'Controls'|i18n( 'extension/expqueue' )}</span></th>{/if}</tr></thead>
<tbody>
{foreach $resources as $r}
<tr{if $r.paused} class="is-paused"{/if}>
<td><a href={concat( '/expqueue/list/(state)/active/(resource)/', $r.key )|ezurl}><code>{$r.key|wash}</code></a></td>
<td class="q-num">{$r.running} / {$r.limit}{if ne( $r.limit, $r.max )}<span class="q-meta"> ({'max %n'|i18n( 'extension/expqueue',, hash( '%n', $r.max ) )})</span>{/if}</td>
<td class="q-num">{$r.ready}</td>
<td>{if $r.paused}{include uri='design:expqueue/parts/state.tpl' state='paused'}{elseif $r.cooling}<span class="q-badge is-held">{'cooldown %t'|i18n( 'extension/expqueue',, hash( '%t', $r.cooling_label ) )}</span>{else}<span class="q-meta">{if ne( $r.last_status, '' )}{'last %s'|i18n( 'extension/expqueue',, hash( '%s', $r.last_status ) )|wash}{else}{'ok'|i18n( 'extension/expqueue' )}{/if}</span>{/if}</td>
{if $can_manage}<td>{if $r.paused}{include uri='design:expqueue/parts/button.tpl' action='resume' scope='resource' name=$r.key here=$here label='Resume'|i18n( 'extension/expqueue' )}{else}{include uri='design:expqueue/parts/button.tpl' action='pause' scope='resource' name=$r.key here=$here label='Pause'|i18n( 'extension/expqueue' )}{/if}</td>{/if}
</tr>
{/foreach}
</tbody>
</table>
{/if}
</section>

<section class="q-card" aria-labelledby="q-workers-title">
<h2 class="q-h2" id="q-workers-title">{'Workers'|i18n( 'extension/expqueue' )}</h2>
<dl class="q-facts">
<dt>{'Cron part expqueue'|i18n( 'extension/expqueue' )}</dt>
<dd>{if $cron.last}{if $cron.ok}<span class="q-badge is-done">{'ran %t ago'|i18n( 'extension/expqueue',, hash( '%t', $cron.ago_label ) )}</span>{else}<span class="q-badge is-dead">{'late: last run %t ago'|i18n( 'extension/expqueue',, hash( '%t', $cron.ago_label ) )}</span>{/if}{else}<span class="q-badge is-dead">{'never ran'|i18n( 'extension/expqueue' )}</span> <span class="q-meta">{'add php runcronjobs.php -q expqueue to the crontab (every minute)'|i18n( 'extension/expqueue' )}</span>{/if}</dd>
<dt>{'systemd service'|i18n( 'extension/expqueue' )}</dt>
<dd>{if $service.installed}<span class="q-badge is-done">{'installed'|i18n( 'extension/expqueue' )}</span> <code>{$service.unit|wash}</code> <span class="q-meta">{'%n worker(s) alive'|i18n( 'extension/expqueue',, hash( '%n', $service.workers ) )}</span>{else}<span class="q-meta">{'not installed: cron is the worker'|i18n( 'extension/expqueue' )} (<code>./console ext:expqueue:service install</code>)</span>{/if}</dd>
</dl>
{if $workers|count|gt( 0 )}
<table class="q-table" style="margin-top:8px">
<thead><tr><th>{'Worker'|i18n( 'extension/expqueue' )}</th><th>{'Started by'|i18n( 'extension/expqueue' )}</th><th class="q-num">{'Up'|i18n( 'extension/expqueue' )}</th><th class="q-num">{'Heartbeat'|i18n( 'extension/expqueue' )}</th><th class="q-num">{'Done'|i18n( 'extension/expqueue' )}</th></tr></thead>
<tbody>
{foreach $workers as $w}
<tr><td><code>{$w.host|wash}:{$w.pid}</code>{if $w.current} <span class="q-meta">{'job %id'|i18n( 'extension/expqueue',, hash( '%id', $w.current ) )}</span>{/if}</td><td>{$w.origin|wash} <span class="q-meta">({$w.os_user|wash})</span></td><td class="q-num">{$w.up|wash}</td><td class="q-num">{$w.beat|wash}</td><td class="q-num">{$w.done}</td></tr>
{/foreach}
</tbody>
</table>
{else}
<p class="q-empty" style="margin-top:8px">{'No worker is running right now; the next cron run starts one when jobs are ready.'|i18n( 'extension/expqueue' )}</p>
{/if}
</section>

<section class="q-card" aria-labelledby="q-running-title">
<h2 class="q-h2" id="q-running-title">{'Running now'|i18n( 'extension/expqueue' )}</h2>
{if $running_jobs|count|eq( 0 )}
<p class="q-empty">{'Nothing runs.'|i18n( 'extension/expqueue' )}</p>
{else}
<table class="q-table"><tbody>
{foreach $running_jobs as $j}
<tr><td><a href={concat( '/expqueue/job/', $j.uuid )|ezurl}>{$j.summary|wash}</a> <span class="q-meta">{$j.class|wash}</span></td>
<td style="width:30%">{if ge( $j.progress, 0 )}<div class="q-progress" role="progressbar" aria-valuenow="{$j.progress}" aria-valuemin="0" aria-valuemax="100"><span style="width: {$j.progress}%"></span></div>{else}<span class="q-meta">{$j.run|wash}</span>{/if}</td></tr>
{/foreach}
</tbody></table>
{/if}
</section>

<section class="q-card" aria-labelledby="q-dead-title">
<h2 class="q-h2" id="q-dead-title">{'Dead letter'|i18n( 'extension/expqueue' )} {if gt( $states.dead, 0 )}<a class="q-meta" href={'/expqueue/list/(state)/dead'|ezurl}>{'all %n'|i18n( 'extension/expqueue',, hash( '%n', $states.dead ) )}</a>{/if}
{if and( $can_manage, gt( $states.dead, 0 ) )}{include uri='design:expqueue/parts/button.tpl' action='retry_dead' here=$here label='Requeue all'|i18n( 'extension/expqueue' ) confirm='Put every dead job back into the queue with its attempts reset?'|i18n( 'extension/expqueue' )}{/if}</h2>
{if $dead_recent|count|eq( 0 )}
<p class="q-empty">{'Empty: no job has failed for good.'|i18n( 'extension/expqueue' )}</p>
{else}
<table class="q-table"><tbody>
{foreach $dead_recent as $j}
<tr><td><a href={concat( '/expqueue/job/', $j.uuid )|ezurl}>{$j.summary|wash}</a><br /><span class="q-meta">{$j.error|wash}</span></td><td class="q-num q-meta">{$j.age|wash}</td></tr>
{/foreach}
</tbody></table>
{/if}
</section>

<section class="q-card" aria-labelledby="q-groups-title">
<h2 class="q-h2" id="q-groups-title">{'Groups'|i18n( 'extension/expqueue' )}</h2>
{if $groups|count|eq( 0 )}
<p class="q-empty">{'No job group yet.'|i18n( 'extension/expqueue' )}</p>
{else}
<table class="q-table"><tbody>
{foreach $groups as $g}
<tr><td><a href={concat( '/expqueue/group/', $g.uuid )|ezurl}>{$g.label|wash}</a> {include uri='design:expqueue/parts/state.tpl' state=$g.state}</td>
<td style="width:34%"><div class="q-progress" role="progressbar" aria-valuenow="{$g.progress.percent}" aria-valuemin="0" aria-valuemax="100" title="{$g.progress.percent}%"><span style="width: {$g.progress.percent}%"></span></div></td>
<td class="q-num q-meta">{$g.progress.done}/{$g.progress.total}</td></tr>
{/foreach}
</tbody></table>
{/if}
</section>

</div>

{include uri='design:expqueue/parts/footer.tpl'}
{undef $here}
