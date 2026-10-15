{* expqueue/job/<uuid>: one job. Its payload is shown masked and shortened (secrets do not belong in a payload). *}
{set-block variable=$status}
{include uri='design:expqueue/parts/state.tpl' state=$job.state}
{if $can_manage}
{if $job.can_cancel}{include uri='design:expqueue/parts/button.tpl' action='cancel' job=$job.uuid here=$here label='Cancel'|i18n( 'extension/expqueue' ) kind='danger' confirm='Cancel this job?'|i18n( 'extension/expqueue' )}{/if}
{if $job.can_retry}{include uri='design:expqueue/parts/button.tpl' action='retry' job=$job.uuid here=$here label='Requeue'|i18n( 'extension/expqueue' ) kind='primary'}{/if}
{/if}
{/set-block}
{include uri='design:expqueue/parts/header.tpl' title=$job.summary status=$status}

<div class="a4-grid is-wide a4-queue-grid">
<section class="a4-card" aria-labelledby="q-job-title">
<div class="a4-card-head"><h2 class="a4-h2" id="q-job-title">{'Job'|i18n( 'extension/expqueue' )}</h2></div>
<dl class="a4-facts is-rows">
<dt>{'Id'|i18n( 'extension/expqueue' )}</dt><dd><code>{$job.uuid|wash}</code> <span class="a4-meta">#{$job.id}</span></dd>
<dt>{'Type'|i18n( 'extension/expqueue' )}</dt><dd><a href={concat( '/expqueue/list/(type)/', $job.type )|ezurl}><code>{$job.type|wash}</code></a></dd>
<dt>{'Class'|i18n( 'extension/expqueue' )}</dt><dd>{$job.class|wash}, {'priority %p'|i18n( 'extension/expqueue',, hash( '%p', $job.priority ) )}</dd>
{if ne( $job.resource, '' )}<dt>{'Resource'|i18n( 'extension/expqueue' )}</dt><dd><code>{$job.resource|wash}</code></dd>{/if}
<dt>{'Attempts'|i18n( 'extension/expqueue' )}</dt><dd>{$job.attempts|wash}, {'timeout %t'|i18n( 'extension/expqueue',, hash( '%t', $job.timeout ) )}</dd>
<dt>{'Queued'|i18n( 'extension/expqueue' )}</dt><dd>{$job.created|l10n( 'shortdatetime' )} <span class="a4-meta">({'%t ago'|i18n( 'extension/expqueue',, hash( '%t', $job.age ) )})</span></dd>
{if $job.started}<dt>{'Started'|i18n( 'extension/expqueue' )}</dt><dd>{$job.started|l10n( 'shortdatetime' )} <span class="a4-meta">({'waited %w, ran %r'|i18n( 'extension/expqueue',, hash( '%w', $job.wait, '%r', $job.run ) )})</span></dd>{/if}
{if $job.finished}<dt>{'Ended'|i18n( 'extension/expqueue' )}</dt><dd>{$job.finished|l10n( 'shortdatetime' )}</dd>{/if}
{if ne( $job.run_after_in, '' )}<dt>{'Next attempt'|i18n( 'extension/expqueue' )}</dt><dd>{'in %t'|i18n( 'extension/expqueue',, hash( '%t', $job.run_after_in ) )}</dd>{/if}
{if ne( $job.lease_left, '' )}<dt>{'Lease'|i18n( 'extension/expqueue' )}</dt><dd><code>{$job.lease_owner|wash}</code> <span class="a4-meta">{'%t left'|i18n( 'extension/expqueue',, hash( '%t', $job.lease_left ) )}</span></dd>{/if}
<dt>{'Queued by'|i18n( 'extension/expqueue' )}</dt><dd>{$user_name|wash}{if ne( $job.site, '' )} <span class="a4-meta">({$job.site|wash})</span>{/if}</dd>
{if ne( $job.idempotency_key, '' )}<dt>{'Idempotency key'|i18n( 'extension/expqueue' )}</dt><dd><code>{$job.idempotency_key|wash}</code></dd>{/if}
{if $group}<dt>{'Group'|i18n( 'extension/expqueue' )}</dt><dd><a href={concat( '/expqueue/group/', $group.uuid )|ezurl}>{$group.label|wash}</a></dd>{/if}
{if $parent}<dt>{'After'|i18n( 'extension/expqueue' )}</dt><dd><a href={concat( '/expqueue/job/', $parent.uuid )|ezurl}>{$parent.summary|wash}</a> {include uri='design:expqueue/parts/state.tpl' state=$parent.state}</dd>{/if}
{if ne( $job.lane, '' )}<dt>{'Lane'|i18n( 'extension/expqueue' )}</dt><dd>{$job.lane|wash}</dd>{/if}
{if ne( $job.error, '' )}<dt>{'Last error'|i18n( 'extension/expqueue' )}</dt><dd>{$job.error|wash}{if ne( $job.error_class, '' )} <span class="a4-meta">({$job.error_class|wash})</span>{/if}</dd>{/if}
</dl>
{if ge( $job.progress, 0 )}
<div class="a4-queue-after"><div class="a4-meter" role="progressbar" aria-label="{'Progress'|i18n( 'extension/expqueue' )|wash}" aria-valuenow="{$job.progress}" aria-valuemin="0" aria-valuemax="100"><span class="a4-pct-{$job.progress}"></span></div>
<p class="a4-meta">{$job.progress}%{if ne( $job.progress_label, '' )} · {$job.progress_label|wash}{/if}{if ne( $job.progress_message, '' )} · {$job.progress_message|wash}{/if}</p></div>
{/if}
</section>

<section class="a4-card" aria-labelledby="q-payload-title">
<div class="a4-card-head"><h2 class="a4-h2" id="q-payload-title">{'Parameters'|i18n( 'extension/expqueue' )}</h2></div>
{if $payload|count|eq( 0 )}<p class="a4-empty">{'None.'|i18n( 'extension/expqueue' )}</p>{else}
<dl class="a4-facts is-rows">{foreach $payload as $k => $v}<dt><code>{$k|wash}</code></dt><dd>{$v|wash}</dd>{/foreach}</dl>{/if}
<div class="a4-card-head"><h2 class="a4-h2">{'Result'|i18n( 'extension/expqueue' )}{if $has_checkpoint} <span class="a4-badge">{'checkpoint saved (%n bytes)'|i18n( 'extension/expqueue',, hash( '%n', $checkpoint_bytes ) )}</span>{/if}</h2></div>
{if $result|count|eq( 0 )}<p class="a4-empty">{'None yet.'|i18n( 'extension/expqueue' )}</p>{else}
<dl class="a4-facts is-rows">{foreach $result as $k => $v}<dt><code>{$k|wash}</code></dt><dd>{$v|wash}</dd>{/foreach}</dl>{/if}
</section>

<section class="a4-card a4-queue-span" aria-labelledby="q-events-title">
<div class="a4-card-head"><h2 class="a4-h2" id="q-events-title">{'History'|i18n( 'extension/expqueue' )} <span class="a4-meta">{'%n event(s)'|i18n( 'extension/expqueue',, hash( '%n', $events|count ) )}</span></h2></div>
<div class="a4-queue-scroll" tabindex="0" role="region" aria-labelledby="q-events-title">
<table class="a4-table is-compact">
<thead><tr><th>{'Time'|i18n( 'extension/expqueue' )}</th><th>{'Event'|i18n( 'extension/expqueue' )}</th><th class="a4-num">{'Attempt'|i18n( 'extension/expqueue' )}</th><th>{'Message'|i18n( 'extension/expqueue' )}</th><th class="a4-queue-hide-narrow">{'Worker'|i18n( 'extension/expqueue' )}</th></tr></thead>
<tbody>
{foreach $events as $e}
<tr><td class="a4-meta a4-nowrap">{$e.ts|l10n( 'shortdatetime' )}</td><td>{include uri='design:expqueue/parts/state.tpl' state=$e.kind}</td><td class="a4-num">{if $e.attempt}{$e.attempt}{/if}</td>
<td>{$e.message|wash}{if $e.data|count|gt( 0 )}<br /><span class="a4-meta">{foreach $e.data as $k => $v}{$k|wash}={$v|wash}{delimiter}, {/delimiter}{/foreach}</span>{/if}</td>
<td class="a4-queue-hide-narrow a4-meta"><code>{$e.worker|wash}</code></td></tr>
{/foreach}
</tbody>
</table>
</div>
</section>
</div>

{include uri='design:expqueue/parts/footer.tpl'}
