{* One control of the job queue: a small POST form to expqueue/action (ezformtoken adds its token to every POST form).
   Input: $action, $label, $here (the page to come back to); optional $scope, $name, $job, $group, $kind (primary, danger),
   $confirm (a question asked before it is sent). Shown only to users with expqueue/manage (the caller checks). *}
<form class="q-inline" method="post" action={'/expqueue/action'|ezurl}{if is_set( $confirm )} onsubmit="return window.confirm( this.getAttribute( 'data-confirm' ) );" data-confirm="{$confirm|wash}"{/if}>
<input type="hidden" name="Action" value="{$action|wash}" />
<input type="hidden" name="RedirectURI" value="{$here|wash}" />
{if is_set( $scope )}<input type="hidden" name="Scope" value="{$scope|wash}" />{/if}
{if is_set( $name )}<input type="hidden" name="Name" value="{$name|wash}" />{/if}
{if is_set( $job )}<input type="hidden" name="Job" value="{$job|wash}" />{/if}
{if is_set( $group )}<input type="hidden" name="Group" value="{$group|wash}" />{/if}
<button type="submit" class="q-btn{if is_set( $kind )} is-{$kind|wash}{/if}"{if is_set( $title )} title="{$title|wash}"{/if}>{$label|wash}</button>
</form>
