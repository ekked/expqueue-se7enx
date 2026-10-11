<?php
/**
 * expqueue/dashboard: the queue at a glance (the same report as ./console ext:expqueue:status).
 */

if ( !expQueue::installed() )
{
    $Result = expQueueAdmin::notInstalled();
    return;
}
$report = expQueueStats::report();
$tpl = eZTemplate::factory();
$classes = array();
foreach ( $report['classes'] as $c )
    $classes[] = $c + array( 'oldest_label' => $c['ready'] ? expQueueAdmin::duration( $c['oldest_wait'] ) : '–',
                             'p95_label' => $c['wait_p95'] === null ? '–' : expQueueAdmin::duration( $c['wait_p95'] ) );
$resources = array();
foreach ( $report['resources'] as $r )
    $resources[] = $r + array( 'cooling_label' => $r['cooling'] ? expQueueAdmin::duration( $r['cooling'] ) : '' );
$workers = array();
foreach ( $report['workers'] as $w )
    $workers[] = array( 'id' => $w['worker_id'], 'origin' => $w['origin'], 'os_user' => $w['os_user'], 'host' => $w['host'], 'pid' => (int) $w['pid'],
                        'up' => expQueueAdmin::duration( $report['generated'] - (int) $w['started'] ),
                        'beat' => expQueueAdmin::duration( $report['generated'] - (int) $w['heartbeat'] ),
                        'done' => (int) $w['jobs_done'], 'current' => (int) $w['current_job'], 'filter' => $w['filter'] );
$hourly = $report['hourly'];
$tpl->setVariable( 'view', 'dashboard' );
$tpl->setVariable( 'can_manage', expQueueAdmin::canManage() );
$tpl->setVariable( 'flash', expQueueAdmin::takeFlash() );
$tpl->setVariable( 'paused', $report['paused'] );
$tpl->setVariable( 'paused_by_setting', $report['paused_by_setting'] );
$tpl->setVariable( 'states', $report['states'] );
$tpl->setVariable( 'totals', $report['totals'] + array( 'oldest_label' => $report['totals']['oldest_wait'] ? expQueueAdmin::duration( $report['totals']['oldest_wait'] ) : '–' ) );
$tpl->setVariable( 'classes', $classes );
$tpl->setVariable( 'resources', $resources );
$tpl->setVariable( 'hourly', $hourly );
$tpl->setVariable( 'hourly_max', $hourly ? (int) $hourly[0]['max'] : 0 );
$tpl->setVariable( 'hourly_done', array_sum( array_map( function ( $h ) { return $h['done']; }, $hourly ) ) );
$tpl->setVariable( 'hourly_dead', array_sum( array_map( function ( $h ) { return $h['dead']; }, $hourly ) ) );
$tpl->setVariable( 'workers', $workers );
$tpl->setVariable( 'cron', $report['cron'] + array( 'ago_label' => $report['cron']['last'] ? expQueueAdmin::duration( $report['cron']['ago'] ) : '' ) );
$tpl->setVariable( 'service', $report['service'] );
$tpl->setVariable( 'dead_recent', array_map( array( 'expQueueAdmin', 'jobRow' ), $report['dead_recent'] ) );
$tpl->setVariable( 'running_jobs', array_map( array( 'expQueueAdmin', 'jobRow' ), $report['running_jobs'] ) );
$tpl->setVariable( 'groups', array_map( array( 'expQueueAdmin', 'groupRow' ), $report['groups'] ) );

$Result = expQueueAdmin::result( 'dashboard', $tpl->fetch( 'design:expqueue/dashboard.tpl' ),
                                 array( ezpI18n::tr( 'extension/expqueue', 'Dashboard' ) ) );
