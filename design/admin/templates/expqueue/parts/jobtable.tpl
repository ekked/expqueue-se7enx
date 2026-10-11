{* A table of jobs. Input: $jobs (rows of expQueueAdmin::jobRow()), $here, $can_manage. *}
<div class="q-scroll">
<table class="q-table">
<thead><tr>
<th>{'Job'|i18n( 'extension/expqueue' )}</th>
<th>{'State'|i18n( 'extension/expqueue' )}</th>
<th>{'Class'|i18n( 'extension/expqueue' )}</th>
<th class="q-num q-hide-narrow">{'Priority'|i18n( 'extension/expqueue' )}</th>
<th class="q-hide-narrow">{'Resource'|i18n( 'extension/expqueue' )}</th>
<th class="q-num">{'Attempts'|i18n( 'extension/expqueue' )}</th>
<th class="q-num">{'Age'|i18n( 'extension/expqueue' )}</th>
{if $can_manage}<th><span class="q-sr">{'Controls'|i18n( 'extension/expqueue' )}</span></th>{/if}
</tr></thead>
<tbody>
{foreach $jobs as $j}
<tr>
<td><a href={concat( '/expqueue/job/', $j.uuid )|ezurl}>{$j.summary|wash}</a> <span class="q-meta q-mono">{$j.short|wash}</span>{if ne( $j.error, '' )}<br /><span class="q-meta">{$j.error|shorten( 110 )|wash}</span>{/if}</td>
<td>{include uri='design:expqueue/parts/state.tpl' state=$j.state}{if ne( $j.run_after_in, '' )} <span class="q-meta">{'in %t'|i18n( 'extension/expqueue',, hash( '%t', $j.run_after_in ) )}</span>{/if}{if $j.cancel_requested} <span class="q-meta">{'cancel requested'|i18n( 'extension/expqueue' )}</span>{/if}</td>
<td>{$j.class|wash}</td>
<td class="q-num q-hide-narrow">{$j.priority}</td>
<td class="q-hide-narrow">{if ne( $j.resource, '' )}<code>{$j.resource|wash}</code>{/if}</td>
<td class="q-num">{$j.attempts|wash}</td>
<td class="q-num">{$j.age|wash}</td>
{if $can_manage}<td><div class="q-actions">{if $j.can_cancel}{include uri='design:expqueue/parts/button.tpl' action='cancel' job=$j.uuid here=$here label='Cancel'|i18n( 'extension/expqueue' ) kind='danger'}{/if}{if $j.can_retry}{include uri='design:expqueue/parts/button.tpl' action='retry' job=$j.uuid here=$here label='Requeue'|i18n( 'extension/expqueue' )}{/if}</div></td>{/if}
</tr>
{/foreach}
</tbody>
</table>
</div>
