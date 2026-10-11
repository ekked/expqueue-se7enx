<?php
/**
 * expqueue/action: the controls of the admin pages (POST only; ezformtoken checks the form token, the policy
 * expqueue/manage is required by the view). Redirects back to the page it came from (a path of this module only).
 *
 *   Action=pause|resume       Scope=queue|class|resource|group, Name=<class|resource|group uuid>
 *   Action=cancel|retry       Job=<uuid>
 *   Action=retry_dead         (every dead job)
 *   Action=cancel_group       Group=<uuid>
 *   Action=test_job           queues an expqueue.noop job (checks that a worker picks jobs up)
 */

/** @var eZModule $Module */
$Module = $Params['Module'];
$http = eZHTTPTool::instance();
if ( $_SERVER['REQUEST_METHOD'] !== 'POST' || !$http->hasPostVariable( 'Action' ) )
    return $Module->redirectTo( '/expqueue/dashboard' );
if ( !class_exists( 'ezxFormToken' ) )
{
    expQueueAdmin::flash( ezpI18n::tr( 'extension/expqueue', 'The controls need the extension ezformtoken.' ), 'bad' );
    return $Module->redirectTo( '/expqueue/dashboard' );
}
$back = expQueueAdmin::backTo( $http->hasPostVariable( 'RedirectURI' ) ? $http->postVariable( 'RedirectURI' ) : '' );
$post = function ( $name ) use ( $http ) { return $http->hasPostVariable( $name ) ? trim( (string) $http->postVariable( $name ) ) : ''; };
$action = $post( 'Action' );
$t = function ( $text, array $args = array() ) { return ezpI18n::tr( 'extension/expqueue', $text, null, $args ); };
try
{
    switch ( $action )
    {
        case 'pause':
        case 'resume':
            $scope = $post( 'Scope' );
            $name = $post( 'Name' );
            if ( !in_array( $scope, array( 'queue', 'class', 'resource', 'group' ), true ) )
                throw new expQueueException( 'unknown scope' );
            $ok = $action === 'pause' ? expQueue::pause( $scope, $name ) : expQueue::resume( $scope, $name );
            $label = $scope === 'queue' ? $t( 'the queue' ) : $scope . ' ' . $name;
            expQueueAdmin::flash( $ok ? ( $action === 'pause' ? $t( 'Paused %what.', array( '%what' => $label ) ) : $t( 'Resumed %what.', array( '%what' => $label ) ) )
                                      : $t( 'Nothing changed.' ), $ok ? 'ok' : 'warn' );
            break;
        case 'cancel':
            $state = expQueue::cancel( $post( 'Job' ), 'cancelled in the administration by user ' . eZUser::currentUserID() );
            expQueueAdmin::flash( $state === null ? $t( 'The job had already ended.' )
                                  : ( $state === 'running' ? $t( 'Cancel requested: the job stops at its next check.' ) : $t( 'The job is cancelled.' ) ),
                                  $state === null ? 'warn' : 'ok' );
            break;
        case 'retry':
            $ok = expQueue::retry( $post( 'Job' ) );
            expQueueAdmin::flash( $ok ? $t( 'The job is back in the queue.' ) : $t( 'The job cannot be requeued.' ), $ok ? 'ok' : 'warn' );
            break;
        case 'retry_dead':
            $n = expQueue::retryDead();
            expQueueAdmin::flash( $t( '%count dead job(s) are back in the queue.', array( '%count' => $n ) ) );
            break;
        case 'cancel_group':
            $n = expQueue::cancelGroup( $post( 'Group' ), 'the group was cancelled in the administration' );
            expQueueAdmin::flash( $t( 'The group is cancelled (%count job(s)).', array( '%count' => $n ) ) );
            break;
        case 'test_job':
            $job = expQueue::enqueue( 'expqueue.noop', array( 'echo' => 'test job from the dashboard' ), array( 'class' => 'system' ) );
            expQueueAdmin::flash( $t( 'A test job is queued; a worker (cron within a minute, or the service) runs it.' ) );
            $back = '/expqueue/job/' . $job->attribute( 'uuid' );
            break;
        default:
            expQueueAdmin::flash( $t( 'Unknown action.' ), 'bad' );
    }
}
catch ( expQueueException $e )
{
    expQueueAdmin::flash( $e->getMessage(), 'bad' );
}
return $Module->redirectTo( $back );
