{* The badge of a job or group state, or of an event of a job's history. Input: $state. *}
{def $names = hash( 'queued', 'queued'|i18n( 'extension/expqueue/state' ),
                    'ready', 'ready'|i18n( 'extension/expqueue/state' ),
                    'running', 'running'|i18n( 'extension/expqueue/state' ),
                    'retry', 'retry'|i18n( 'extension/expqueue/state' ),
                    'held', 'held'|i18n( 'extension/expqueue/state' ),
                    'done', 'done'|i18n( 'extension/expqueue/state' ),
                    'dead', 'dead'|i18n( 'extension/expqueue/state' ),
                    'cancelled', 'cancelled'|i18n( 'extension/expqueue/state' ),
                    'active', 'active'|i18n( 'extension/expqueue/state' ),
                    'paused', 'paused'|i18n( 'extension/expqueue/state' ) )
     $tones = hash( 'ready', 'info', 'active', 'info', 'running', 'warn', 'done', 'ok', 'dead', 'bad', 'paused', 'warn', 'held', 'warn' )}
<span class="a4-badge{if is_set( $tones[$state] )} is-{$tones[$state]}{/if}">{if is_set( $names[$state] )}{$names[$state]|wash}{else}{$state|wash}{/if}</span>
{undef $names $tones}
