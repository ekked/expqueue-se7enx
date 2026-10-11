{* expqueue/group/<uuid>: a job group, its progress and its jobs. *}
{set-block variable=$status}
{include uri='design:expqueue/parts/state.tpl' state=$group.state}
{if $can_manage}
{if $group.can_pause}{include uri='design:expqueue/parts/button.tpl' action='pause' scope='group' name=$group.uuid here=$here label='Pause'|i18n( 'extension/expqueue' )}{/if}
{if $group.can_resume}{include uri='design:expqueue/parts/button.tpl' action='resume' scope='group' name=$group.uuid here=$here label='Resume'|i18n( 'extension/expqueue' ) kind='primary'}{/if}
{if $group.can_cancel}{include uri='design:expqueue/parts/button.tpl' action='cancel_group' group=$group.uuid here=$here label='Cancel group'|i18n( 'extension/expqueue' ) kind='danger' confirm='Cancel every job of this group that has not ended?'|i18n( 'extension/expqueue' )}{/if}
{/if}
{/set-block}
{include uri='design:expqueue/parts/header.tpl' title=$group.label status=$status}

<section class="q-card q-section" aria-labelledby="q-group-title">
<h2 class="q-h2" id="q-group-title">{'Progress'|i18n( 'extension/expqueue' )} <span class="q-meta">{'%done of %total ended (%percent%)'|i18n( 'extension/expqueue',, hash( '%done', sub( $group.progress.total, $group.progress.active ), '%total', $group.progress.total, '%percent', $group.progress.percent ) )}</span></h2>
<div class="q-progress" role="progressbar" aria-valuenow="{$group.progress.percent}" aria-valuemin="0" aria-valuemax="100"><span style="width: {$group.progress.percent}%"></span></div>
<ul class="q-chips" style="margin-top:10px">
{foreach $counts as $s => $n}{if gt( $n, 0 )}<li><a href={concat( '/expqueue/list/(state)/', $s, '/(group)/', $group.uuid )|ezurl}>{$s|i18n( 'extension/expqueue/state' )|wash} <small>{$n}</small></a></li>{/if}{/foreach}
</ul>
<dl class="q-facts" style="margin-top:10px">
<dt>{'Id'|i18n( 'extension/expqueue' )}</dt><dd><code>{$group.uuid|wash}</code></dd>
{if ne( $group.type, '' )}<dt>{'Type'|i18n( 'extension/expqueue' )}</dt><dd><code>{$group.type|wash}</code></dd>{/if}
<dt>{'Created'|i18n( 'extension/expqueue' )}</dt><dd>{$group.created|l10n( 'shortdatetime' )} <span class="q-meta">{$user_name|wash}</span></dd>
</dl>
</section>

{if $jobs|count|eq( 0 )}
<p class="q-empty">{'The group has no job.'|i18n( 'extension/expqueue' )}</p>
{else}
{include uri='design:expqueue/parts/jobtable.tpl' jobs=$jobs here=$here can_manage=$can_manage}
<p class="q-pager">{if ne( $prev_url, '' )}<a href={$prev_url|ezurl}>{'Newer'|i18n( 'extension/expqueue' )}</a>{/if}{if ne( $next_url, '' )}<a href={$next_url|ezurl}>{'Older'|i18n( 'extension/expqueue' )}</a>{/if}</p>
{/if}

{include uri='design:expqueue/parts/footer.tpl'}
