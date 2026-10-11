{* Opening of every Setup > Job queue page: the style, the title, the tabs and the message of the last action.
   Input: $view (dashboard, list, job, group), $title, $flash (optional), $status (optional: shown right of the tabs).
   Closed by expqueue/parts/footer.tpl. *}
{include uri='design:expqueue/parts/style.tpl'}
<div class="context-block exp-queue-page">

<div class="box-header"><div class="box-ml">
<h1 class="context-title">{$title|wash}</h1>
</div></div>

<div class="box-bc"><div class="box-ml"><div class="box-content">

<div class="q-top">
<nav aria-label="{'Job queue'|i18n( 'extension/expqueue' )|wash}">
<ul class="q-tabs">
    <li><a href={'/expqueue/dashboard'|ezurl}{if eq( $view, 'dashboard' )} aria-current="page"{/if}>{'Dashboard'|i18n( 'extension/expqueue' )}</a></li>
    <li><a href={'/expqueue/list/(state)/active'|ezurl}{if eq( $view, 'list' )} aria-current="page"{/if}>{'Jobs'|i18n( 'extension/expqueue' )}</a></li>
    <li><a href={'/expqueue/list/(state)/dead'|ezurl}>{'Dead letter'|i18n( 'extension/expqueue' )}</a></li>
</ul>
</nav>
{if is_set( $status )}<div class="q-status">{$status}</div>{/if}
</div>

{if and( is_set( $flash ), $flash )}
<p class="q-flash{if ne( $flash.kind, 'ok' )} is-{$flash.kind|wash}{/if}" role="status">{$flash.message|wash}</p>
{/if}
