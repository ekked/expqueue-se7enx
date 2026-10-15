{* Opening of every Setup > Job queue page: the title, the tabs and the message of the last action. The look comes
   from the shared components and design/admin/stylesheets/expqueue.css (design.ini BackendCSSFileList).
   Input: $view (dashboard, list, job, group), $title, $flash (optional), $status (optional: shown right of the tabs).
   Closed by expqueue/parts/footer.tpl. *}
<div class="context-block a4-page a4-queue">

<div class="box-header"><div class="box-ml">
<h1 class="context-title">{$title|wash}</h1>
</div></div>

<div class="box-bc"><div class="box-ml"><div class="box-content">

<div class="a4-row is-between a4-queue-top">
<nav aria-label="{'Job queue'|i18n( 'extension/expqueue' )|wash}">
<ul class="a4-tabs">
    <li><a href={'/expqueue/dashboard'|ezurl}{if eq( $view, 'dashboard' )} class="is-current" aria-current="page"{/if}>{'Dashboard'|i18n( 'extension/expqueue' )}</a></li>
    <li><a href={'/expqueue/list/(state)/active'|ezurl}{if eq( $view, 'list' )} class="is-current" aria-current="page"{/if}>{'Jobs'|i18n( 'extension/expqueue' )}</a></li>
    <li><a href={'/expqueue/list/(state)/dead'|ezurl}>{'Dead letter'|i18n( 'extension/expqueue' )}</a></li>
</ul>
</nav>
{if is_set( $status )}<div class="a4-actions">{$status}</div>{/if}
</div>

{if and( is_set( $flash ), $flash )}
<p class="a4-notice is-{if eq( $flash.kind, 'ok' )}ok{else}{$flash.kind|wash}{/if}" role="status">{$flash.message|wash}</p>
{/if}
