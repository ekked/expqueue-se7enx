{* expqueue/list: the jobs, filtered by view parameters (state, class, type, resource, group). *}
{include uri='design:expqueue/parts/header.tpl' title='Jobs'|i18n( 'extension/expqueue' )}

<div class="a4-queue-filters">
<ul class="a4-badges" aria-label="{'State'|i18n( 'extension/expqueue' )|wash}">
<li class="a4-queue-label">{'State'|i18n( 'extension/expqueue' )}</li>
{foreach $state_links as $l}
<li><a class="a4-tag{if $l.current} is-accent{/if}" href={$l.url|ezurl}{if $l.current} aria-current="true"{/if}>{if eq( $l.name, '' )}{'all'|i18n( 'extension/expqueue' )}{else}{$l.name|i18n( 'extension/expqueue/state' )|wash}{/if}{if is_set( $l.count )} <small>{$l.count}</small>{/if}</a></li>
{/foreach}
</ul>
<ul class="a4-badges" aria-label="{'Class'|i18n( 'extension/expqueue' )|wash}">
<li class="a4-queue-label">{'Class'|i18n( 'extension/expqueue' )}</li>
{foreach $class_links as $l}
<li><a class="a4-tag{if $l.current} is-accent{/if}" href={$l.url|ezurl}{if $l.current} aria-current="true"{/if}>{if eq( $l.name, '' )}{'all'|i18n( 'extension/expqueue' )}{else}{$l.name|wash}{/if}</a></li>
{/foreach}
</ul>
{if or( is_set( $active.type ), is_set( $active.resource ), $group )}
<ul class="a4-badges">
<li class="a4-queue-label">{'Also'|i18n( 'extension/expqueue' )}</li>
{if is_set( $active.type )}<li><a class="a4-tag is-accent" href={$type_clear_url|ezurl} aria-current="true">{'type %t ×'|i18n( 'extension/expqueue',, hash( '%t', $active.type ) )|wash}</a></li>{/if}
{if is_set( $active.resource )}<li><a class="a4-tag is-accent" href={$resource_clear_url|ezurl} aria-current="true">{'resource %r ×'|i18n( 'extension/expqueue',, hash( '%r', $active.resource ) )|wash}</a></li>{/if}
{if $group}<li><a class="a4-tag" href={concat( '/expqueue/group/', $group.uuid )|ezurl}>{'group %g'|i18n( 'extension/expqueue',, hash( '%g', $group.label ) )|wash}</a></li>{/if}
</ul>
{/if}
</div>

{if and( $can_manage, is_set( $active.state ), eq( $active.state, 'dead' ), $jobs|count|gt( 0 ) )}
<p class="a4-actions a4-queue-gap">{include uri='design:expqueue/parts/button.tpl' action='retry_dead' here=$here label='Requeue all dead jobs'|i18n( 'extension/expqueue' ) confirm='Put every dead job back into the queue with its attempts reset?'|i18n( 'extension/expqueue' )}</p>
{/if}

{if $jobs|count|eq( 0 )}
<p class="a4-empty">{'No job matches.'|i18n( 'extension/expqueue' )}</p>
{else}
{include uri='design:expqueue/parts/jobtable.tpl' jobs=$jobs here=$here can_manage=$can_manage}
<p class="a4-row">
{if ne( $prev_url, '' )}<a href={$prev_url|ezurl}>{'Newer'|i18n( 'extension/expqueue' )}</a>{/if}
<span class="a4-meta">{'%from to %to'|i18n( 'extension/expqueue',, hash( '%from', sum( $offset, 1 ), '%to', sum( $offset, $jobs|count ) ) )}</span>
{if ne( $next_url, '' )}<a href={$next_url|ezurl}>{'Older'|i18n( 'extension/expqueue' )}</a>{/if}
</p>
{/if}

{include uri='design:expqueue/parts/footer.tpl'}
