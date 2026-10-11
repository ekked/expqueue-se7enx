{* expqueue/list: the jobs, filtered by view parameters (state, class, type, resource, group). *}
{include uri='design:expqueue/parts/header.tpl' title='Jobs'|i18n( 'extension/expqueue' )}

<div class="q-filters">
<ul class="q-chips" aria-label="{'State'|i18n( 'extension/expqueue' )|wash}">
<li class="q-label">{'State'|i18n( 'extension/expqueue' )}</li>
{foreach $state_links as $l}
<li><a href={$l.url|ezurl}{if $l.current} aria-current="true"{/if}>{if eq( $l.name, '' )}{'all'|i18n( 'extension/expqueue' )}{else}{$l.name|i18n( 'extension/expqueue/state' )|wash}{/if}{if is_set( $l.count )} <small>{$l.count}</small>{/if}</a></li>
{/foreach}
</ul>
<ul class="q-chips" aria-label="{'Class'|i18n( 'extension/expqueue' )|wash}">
<li class="q-label">{'Class'|i18n( 'extension/expqueue' )}</li>
{foreach $class_links as $l}
<li><a href={$l.url|ezurl}{if $l.current} aria-current="true"{/if}>{if eq( $l.name, '' )}{'all'|i18n( 'extension/expqueue' )}{else}{$l.name|wash}{/if}</a></li>
{/foreach}
</ul>
{if or( is_set( $active.type ), is_set( $active.resource ), $group )}
<ul class="q-chips">
<li class="q-label">{'Also'|i18n( 'extension/expqueue' )}</li>
{if is_set( $active.type )}<li><a href={$type_clear_url|ezurl} aria-current="true">{'type %t ×'|i18n( 'extension/expqueue',, hash( '%t', $active.type ) )|wash}</a></li>{/if}
{if is_set( $active.resource )}<li><a href={$resource_clear_url|ezurl} aria-current="true">{'resource %r ×'|i18n( 'extension/expqueue',, hash( '%r', $active.resource ) )|wash}</a></li>{/if}
{if $group}<li><a href={concat( '/expqueue/group/', $group.uuid )|ezurl}>{'group %g'|i18n( 'extension/expqueue',, hash( '%g', $group.label ) )|wash}</a></li>{/if}
</ul>
{/if}
</div>

{if and( $can_manage, is_set( $active.state ), eq( $active.state, 'dead' ), $jobs|count|gt( 0 ) )}
<p class="q-actions" style="margin-bottom:10px">{include uri='design:expqueue/parts/button.tpl' action='retry_dead' here=$here label='Requeue all dead jobs'|i18n( 'extension/expqueue' ) confirm='Put every dead job back into the queue with its attempts reset?'|i18n( 'extension/expqueue' )}</p>
{/if}

{if $jobs|count|eq( 0 )}
<p class="q-empty">{'No job matches.'|i18n( 'extension/expqueue' )}</p>
{else}
{include uri='design:expqueue/parts/jobtable.tpl' jobs=$jobs here=$here can_manage=$can_manage}
<p class="q-pager">
{if ne( $prev_url, '' )}<a href={$prev_url|ezurl}>{'Newer'|i18n( 'extension/expqueue' )}</a>{/if}
<span class="q-meta">{'%from to %to'|i18n( 'extension/expqueue',, hash( '%from', sum( $offset, 1 ), '%to', sum( $offset, $jobs|count ) ) )}</span>
{if ne( $next_url, '' )}<a href={$next_url|ezurl}>{'Older'|i18n( 'extension/expqueue' )}</a>{/if}
</p>
{/if}

{include uri='design:expqueue/parts/footer.tpl'}
