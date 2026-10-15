{* A table of jobs. Input: $jobs (rows of expQueueAdmin::jobRow()), $here, $can_manage. *}
<div class="a4-table-wrap a4-queue-gap" tabindex="0" role="region" aria-label="{'Jobs'|i18n( 'extension/expqueue' )|wash}">
<table class="a4-table is-compact">
<thead><tr>
<th>{'Job'|i18n( 'extension/expqueue' )}</th>
<th>{'State'|i18n( 'extension/expqueue' )}</th>
<th>{'Class'|i18n( 'extension/expqueue' )}</th>
<th class="a4-num a4-queue-hide-narrow">{'Priority'|i18n( 'extension/expqueue' )}</th>
<th class="a4-queue-hide-narrow">{'Resource'|i18n( 'extension/expqueue' )}</th>
<th class="a4-num">{'Attempts'|i18n( 'extension/expqueue' )}</th>
<th class="a4-num">{'Age'|i18n( 'extension/expqueue' )}</th>
{if $can_manage}<th><span class="a4-sr-only">{'Controls'|i18n( 'extension/expqueue' )}</span></th>{/if}
</tr></thead>
<tbody>
{foreach $jobs as $j}
<tr>
<td><a href={concat( '/expqueue/job/', $j.uuid )|ezurl}>{$j.summary|wash}</a> <span class="a4-meta a4-code">{$j.short|wash}</span>{if ne( $j.error, '' )}<br /><span class="a4-meta">{$j.error|shorten( 110 )|wash}</span>{/if}</td>
<td>{include uri='design:expqueue/parts/state.tpl' state=$j.state}{if ne( $j.run_after_in, '' )} <span class="a4-meta">{'in %t'|i18n( 'extension/expqueue',, hash( '%t', $j.run_after_in ) )}</span>{/if}{if $j.cancel_requested} <span class="a4-meta">{'cancel requested'|i18n( 'extension/expqueue' )}</span>{/if}</td>
<td>{$j.class|wash}</td>
<td class="a4-num a4-queue-hide-narrow">{$j.priority}</td>
<td class="a4-queue-hide-narrow">{if ne( $j.resource, '' )}<code>{$j.resource|wash}</code>{/if}</td>
<td class="a4-num">{$j.attempts|wash}</td>
<td class="a4-num">{$j.age|wash}</td>
{if $can_manage}<td class="a4-queue-controls"><div class="a4-actions">{if $j.can_cancel}{include uri='design:expqueue/parts/button.tpl' action='cancel' job=$j.uuid here=$here label='Cancel'|i18n( 'extension/expqueue' ) kind='danger'}{/if}{if $j.can_retry}{include uri='design:expqueue/parts/button.tpl' action='retry' job=$j.uuid here=$here label='Requeue'|i18n( 'extension/expqueue' )}{/if}</div></td>{/if}
</tr>
{/foreach}
</tbody>
</table>
</div>
