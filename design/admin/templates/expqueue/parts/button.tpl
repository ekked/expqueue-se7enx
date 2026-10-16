{* One control of the job queue: a small POST form to expqueue/action (ezformtoken adds its token to every POST form).
   Input: $action, $label, $here (the page to come back to); optional $scope, $name, $job, $group, $kind (primary, danger),
   $confirm (a question asked before it is sent: data-a4-confirm, asked by admin4's a4_actions.js and, in the other
   administration designs, by javascript/expqueue_confirm.js; no inline handler, so the form works under a Content
   Security Policy). Shown only to users with expqueue/manage (the caller checks). *}
<form class="a4-queue-inline" method="post" action={'/expqueue/action'|ezurl}{if is_set( $confirm )} data-a4-confirm="{$confirm|wash}"{/if}>
<input type="hidden" name="Action" value="{$action|wash}" />
<input type="hidden" name="RedirectURI" value="{$here|wash}" />
{if is_set( $scope )}<input type="hidden" name="Scope" value="{$scope|wash}" />{/if}
{if is_set( $name )}<input type="hidden" name="Name" value="{$name|wash}" />{/if}
{if is_set( $job )}<input type="hidden" name="Job" value="{$job|wash}" />{/if}
{if is_set( $group )}<input type="hidden" name="Group" value="{$group|wash}" />{/if}
<button type="submit" class="a4-btn a4-btn-small{if is_set( $kind )}{if eq( $kind, 'primary' )} a4-btn-primary{elseif eq( $kind, 'danger' )} a4-btn-outline-danger{/if}{/if}"{if is_set( $title )} title="{$title|wash}"{/if}>{$label|wash}</button>
</form>
