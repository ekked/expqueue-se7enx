{* The badge of a job or group state. Input: $state. *}
{def $names = hash( 'queued', 'queued'|i18n( 'extension/expqueue/state' ),
                    'ready', 'ready'|i18n( 'extension/expqueue/state' ),
                    'running', 'running'|i18n( 'extension/expqueue/state' ),
                    'retry', 'retry'|i18n( 'extension/expqueue/state' ),
                    'held', 'held'|i18n( 'extension/expqueue/state' ),
                    'done', 'done'|i18n( 'extension/expqueue/state' ),
                    'dead', 'dead'|i18n( 'extension/expqueue/state' ),
                    'cancelled', 'cancelled'|i18n( 'extension/expqueue/state' ),
                    'active', 'active'|i18n( 'extension/expqueue/state' ),
                    'paused', 'paused'|i18n( 'extension/expqueue/state' ) )}
<span class="q-badge is-{$state|wash}">{if is_set( $names[$state] )}{$names[$state]|wash}{else}{$state|wash}{/if}</span>
{undef $names}
