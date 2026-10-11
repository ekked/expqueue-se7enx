<?php
/**
 * expqueue/group/<uuid>: a job group with its progress and its jobs.
 */

/** @var eZModule $Module */
$Module = $Params['Module'];
/** @var array $Params */
if ( !expQueue::installed() )
{
    $Result = expQueueAdmin::notInstalled();
    return;
}
$group = expQueue::resolveGroup( isset( $Params['UUID'] ) ? (string) $Params['UUID'] : '' );
if ( !$group )
    return $Module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );
$params = isset( $Params['UserParameters'] ) ? (array) $Params['UserParameters'] : array();
$offset = isset( $params['offset'] ) ? max( 0, (int) $params['offset'] ) : 0;
$limit = 50;
$jobs = expQueue::listJobs( array( 'group_id' => (int) $group->attribute( 'id' ) ), $offset, $limit + 1 );
$more = count( $jobs ) > $limit;
$jobs = array_slice( $jobs, 0, $limit );
$row = expQueueAdmin::groupRow( $group );
$counts = array();
foreach ( expQueueJob::states() as $s )
    $counts[$s] = 0;
foreach ( $group->counts() as $s => $n )
    $counts[$s] = (int) $n;

$tpl = eZTemplate::factory();
$tpl->setVariable( 'view', 'group' );
$tpl->setVariable( 'can_manage', expQueueAdmin::canManage() );
$tpl->setVariable( 'flash', expQueueAdmin::takeFlash() );
$tpl->setVariable( 'group', $row );
$tpl->setVariable( 'counts', $counts );
$tpl->setVariable( 'user_name', expQueueAdmin::userName( $group->attribute( 'user_id' ) ) );
$tpl->setVariable( 'jobs', array_map( array( 'expQueueAdmin', 'jobRow' ), $jobs ) );
$tpl->setVariable( 'prev_url', $offset > 0 ? 'expqueue/group/' . $row['uuid'] . ( $offset - $limit > 0 ? '/(offset)/' . ( $offset - $limit ) : '' ) : '' );
$tpl->setVariable( 'next_url', $more ? 'expqueue/group/' . $row['uuid'] . '/(offset)/' . ( $offset + $limit ) : '' );
$tpl->setVariable( 'here', '/expqueue/group/' . $row['uuid'] );

$Result = expQueueAdmin::result( 'group', $tpl->fetch( 'design:expqueue/group.tpl' ),
                                 array( ezpI18n::tr( 'extension/expqueue', 'Group' ), $row['label'] ) );
