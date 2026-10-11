{* expqueue/job/<uuid>: one job. Its payload is shown masked and shortened (secrets do not belong in a payload). *}
{set-block variable=$status}
{include uri='design:expqueue/parts/state.tpl' state=$job.state}
{if $can_manage}
{if $job.can_cancel}{include uri='design:expqueue/parts/button.tpl' action='cancel' job=$job.uuid here=$here label='Cancel'|i18n( 'extension/expqueue' ) kind='danger' confirm='Cancel this job?'|i18n( 'extension/expqueue' )}{/if}
{if $job.can_retry}{include uri='design:expqueue/parts/button.tpl' action='retry' job=$job.uuid here=$here label='Requeue'|i18n( 'extension/expqueue' ) kind='primary'}{/if}
{/if}
{/set-block}
{include uri='design:expqueue/parts/header.tpl' title=$job.summary status=$status}

<div class="q-grid">
<section class="q-card" aria-labelledby="q-job-title">
<h2 class="q-h2" id="q-job-title">{'Job'|i18n( 'extension/expqueue' )}</h2>
<dl class="q-facts">
<dt>{'Id'|i18n( 'extension/expqueue' )}</dt><dd><code>{$job.uuid|wash}</code> <span class="q-meta">#{$job.id}</span></dd>
<dt>{'Type'|i18n( 'extension/expqueue' )}</dt><dd><a href={concat( '/expqueue/list/(type)/', $job.type )|ezurl}><code>{$job.type|wash}</code></a></dd>
<dt>{'Class'|i18n( 'extension/expqueue' )}</dt><dd>{$job.class|wash}, {'priority %p'|i18n( 'extension/expqueue',, hash( '%p', $job.priority ) )}</dd>
{if ne( $job.resource, '' )}<dt>{'Resource'|i18n( 'extension/expqueue' )}</dt><dd><code>{$job.resource|wash}</code></dd>{/if}
<dt>{'Attempts'|i18n( 'extension/expqueue' )}</dt><dd>{$job.attempts|wash}, {'timeout %t'|i18n( 'extension/expqueue',, hash( '%t', $job.timeout ) )}</dd>
<dt>{'Queued'|i18n( 'extension/expqueue' )}</dt><dd>{$job.created|l10n( 'shortdatetime' )} <span class="q-meta">({'%t ago'|i18n( 'extension/expqueue',, hash( '%t', $job.age ) )})</span></dd>
{if $job.started}<dt>{'Started'|i18n( 'extension/expqueue' )}</dt><dd>{$job.started|l10n( 'shortdatetime' )} <span class="q-meta">({'waited %w, ran %r'|i18n( 'extension/expqueue',, hash( '%w', $job.wait, '%r', $job.run ) )})</span></dd>{/if}
{if $job.finished}<dt>{'Ended'|i18n( 'extension/expqueue' )}</dt><dd>{$job.finished|l10n( 'shortdatetime' )}</dd>{/if}
{if ne( $job.run_after_in, '' )}<dt>{'Next attempt'|i18n( 'extension/expqueue' )}</dt><dd>{'in %t'|i18n( 'extension/expqueue',, hash( '%t', $job.run_after_in ) )}</dd>{/if}
{if ne( $job.lease_left, '' )}<dt>{'Lease'|i18n( 'extension/expqueue' )}</dt><dd><code>{$job.lease_owner|wash}</code> <span class="q-meta">{'%t left'|i18n( 'extension/expqueue',, hash( '%t', $job.lease_left ) )}</span></dd>{/if}
<dt>{'Queued by'|i18n( 'extension/expqueue' )}</dt><dd>{$user_name|wash}{if ne( $job.site, '' )} <span class="q-meta">({$job.site|wash})</span>{/if}</dd>
{if ne( $job.idempotency_key, '' )}<dt>{'Idempotency key'|i18n( 'extension/expqueue' )}</dt><dd><code>{$job.idempotency_key|wash}</code></dd>{/if}
{if $group}<dt>{'Group'|i18n( 'extension/expqueue' )}</dt><dd><a href={concat( '/expqueue/group/', $group.uuid )|ezurl}>{$group.label|wash}</a></dd>{/if}
{if $parent}<dt>{'After'|i18n( 'extension/expqueue' )}</dt><dd><a href={concat( '/expqueue/job/', $parent.uuid )|ezurl}>{$parent.summary|wash}</a> {include uri='design:expqueue/parts/state.tpl' state=$parent.state}</dd>{/if}
{if ne( $job.lane, '' )}<dt>{'Lane'|i18n( 'extension/expqueue' )}</dt><dd>{$job.lane|wash}</dd>{/if}
{if ne( $job.error, '' )}<dt>{'Last error'|i18n( 'extension/expqueue' )}</dt><dd>{$job.error|wash}{if ne( $job.error_class, '' )} <span class="q-meta">({$job.error_class|wash})</span>{/if}</dd>{/if}
</dl>
{if ge( $job.progress, 0 )}
<div style="margin-top:10px"><div class="q-progress" role="progressbar" aria-valuenow="{$job.progress}" aria-valuemin="0" aria-valuemax="100"><span style="width: {$job.progress}%"></span></div>
<p class="q-meta">{$job.progress}%{if ne( $job.progress_label, '' )} · {$job.progress_label|wash}{/if}{if ne( $job.progress_message, '' )} · {$job.progress_message|wash}{/if}</p></div>
{/if}
</section>

<section class="q-card" aria-labelledby="q-payload-title">
<h2 class="q-h2" id="q-payload-title">{'Parameters'|i18n( 'extension/expqueue' )}</h2>
{if $payload|count|eq( 0 )}<p class="q-empty">{'None.'|i18n( 'extension/expqueue' )}</p>{else}
<dl class="q-facts">{foreach $payload as $k => $v}<dt><code>{$k|wash}</code></dt><dd>{$v|wash}</dd>{/foreach}</dl>{/if}
<h2 class="q-h2" style="margin-top:14px">{'Result'|i18n( 'extension/expqueue' )}{if $has_checkpoint} <span class="q-badge">{'checkpoint saved (%n bytes)'|i18n( 'extension/expqueue',, hash( '%n', $checkpoint_bytes ) )}</span>{/if}</h2>
{if $result|count|eq( 0 )}<p class="q-empty">{'None yet.'|i18n( 'extension/expqueue' )}</p>{else}
<dl class="q-facts">{foreach $result as $k => $v}<dt><code>{$k|wash}</code></dt><dd>{$v|wash}</dd>{/foreach}</dl>{/if}
</section>

<section class="q-card is-wide" aria-labelledby="q-events-title">
<h2 class="q-h2" id="q-events-title">{'History'|i18n( 'extension/expqueue' )} <span class="q-meta">{'%n event(s)'|i18n( 'extension/expqueue',, hash( '%n', $events|count ) )}</span></h2>
<div class="q-scroll">
<table class="q-table">
<thead><tr><th>{'Time'|i18n( 'extension/expqueue' )}</th><th>{'Event'|i18n( 'extension/expqueue' )}</th><th class="q-num">{'Attempt'|i18n( 'extension/expqueue' )}</th><th>{'Message'|i18n( 'extension/expqueue' )}</th><th class="q-hide-narrow">{'Worker'|i18n( 'extension/expqueue' )}</th></tr></thead>
<tbody>
{foreach $events as $e}
<tr><td class="q-meta" style="white-space:nowrap">{$e.ts|l10n( 'shortdatetime' )}</td><td><span class="q-badge is-{$e.kind|wash}">{$e.kind|wash}</span></td><td class="q-num">{if $e.attempt}{$e.attempt}{/if}</td>
<td>{$e.message|wash}{if $e.data|count|gt( 0 )}<br /><span class="q-meta">{foreach $e.data as $k => $v}{$k|wash}={$v|wash}{delimiter}, {/delimiter}{/foreach}</span>{/if}</td>
<td class="q-hide-narrow q-meta"><code>{$e.worker|wash}</code></td></tr>
{/foreach}
</tbody>
</table>
</div>
</section>
</div>

{include uri='design:expqueue/parts/footer.tpl'}
