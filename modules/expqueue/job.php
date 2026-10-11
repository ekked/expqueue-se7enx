<?php
/**
 * expqueue/job/<uuid>: one job with its parameters (masked, shortened), result, checkpoint and history.
 */

/** @var eZModule $Module */
$Module = $Params['Module'];
/** @var array $Params */
if ( !expQueue::installed() )
{
    $Result = expQueueAdmin::notInstalled();
    return;
}
$job = expQueue::fetch( isset( $Params['UUID'] ) ? (string) $Params['UUID'] : '' );
if ( !$job )
    return $Module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );

$events = array();
foreach ( expQueueEvent::fetchForJob( $job->attribute( 'id' ), 300 ) as $e )
    $events[] = array( 'ts' => (int) $e->attribute( 'ts' ), 'kind' => (string) $e->attribute( 'kind' ), 'attempt' => (int) $e->attribute( 'attempt' ),
                       'message' => (string) $e->attribute( 'message' ), 'worker' => (string) $e->attribute( 'worker' ), 'data' => $e->dataSummary() );
$result = $job->resultArray();
$group = $job->group();
$parent = $job->parent();

$tpl = eZTemplate::factory();
$tpl->setVariable( 'view', 'job' );
$tpl->setVariable( 'can_manage', expQueueAdmin::canManage() );
$tpl->setVariable( 'flash', expQueueAdmin::takeFlash() );
$tpl->setVariable( 'job', expQueueAdmin::jobRow( $job ) );
$tpl->setVariable( 'user_name', expQueueAdmin::userName( $job->attribute( 'user_id' ) ) );
$tpl->setVariable( 'payload', $job->payloadSummary() );
$tpl->setVariable( 'result', expQueueJob::summarise( $result ) );
$tpl->setVariable( 'has_checkpoint', $job->checkpointArray() !== null );
$tpl->setVariable( 'checkpoint_bytes', strlen( (string) $job->attribute( 'checkpoint' ) ) );
$tpl->setVariable( 'events', $events );
$tpl->setVariable( 'group', $group ? expQueueAdmin::groupRow( $group ) : null );
$tpl->setVariable( 'parent', $parent ? expQueueAdmin::jobRow( $parent ) : null );
$tpl->setVariable( 'here', '/expqueue/job/' . $job->attribute( 'uuid' ) );

$Result = expQueueAdmin::result( 'job', $tpl->fetch( 'design:expqueue/job.tpl' ),
                                 array( ezpI18n::tr( 'extension/expqueue', 'Jobs' ), substr( (string) $job->attribute( 'uuid' ), 0, 8 ) ) );
