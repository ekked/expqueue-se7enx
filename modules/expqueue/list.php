<?php
/**
 * expqueue/list: the jobs, newest first, filtered by view parameters (state, class, type, resource, group).
 */

/** @var eZModule $Module */
$Module = $Params['Module'];
/** @var array $Params */
if ( !expQueue::installed() )
{
    $Result = expQueueAdmin::notInstalled();
    return;
}
$filter = array();
$params = isset( $Params['UserParameters'] ) ? (array) $Params['UserParameters'] : array();
$clean = function ( $value ) { return substr( preg_replace( '/[^A-Za-z0-9_.:@\/-]/', '', (string) $value ), 0, 80 ); };
$active = array();
foreach ( array( 'state' => 'state', 'class' => 'class', 'type' => 'type', 'resource' => 'resource_key' ) as $param => $field )
{
    if ( isset( $params[$param] ) && $params[$param] !== '' )
    {
        $value = $clean( $params[$param] );
        if ( $param === 'state' && $value === 'active' )
            $filter['state'] = expQueueJob::activeStates();
        elseif ( $value !== '' )
            $filter[$field] = $value;
        $active[$param] = $value;
    }
}
$group = null;
if ( !empty( $params['group'] ) )
{
    $group = expQueue::resolveGroup( $clean( $params['group'] ) );
    $filter['group_id'] = $group ? (int) $group->attribute( 'id' ) : -1;
    $active['group'] = $clean( $params['group'] );
}
$limit = max( 10, min( 200, (int) expQueueConfig::instance()->value( 'AdminSettings', 'ListLimit', 50 ) ) );
$offset = isset( $params['offset'] ) ? max( 0, (int) $params['offset'] ) : 0;
$jobs = expQueue::listJobs( $filter, $offset, $limit + 1 );
$more = count( $jobs ) > $limit;
$jobs = array_slice( $jobs, 0, $limit );

// the link of a filter: the current filters with one changed
$base = function ( array $change ) use ( $active )
{
    $p = array_merge( $active, $change );
    $url = 'expqueue/list';
    foreach ( array( 'state', 'class', 'type', 'resource', 'group' ) as $k )
        if ( isset( $p[$k] ) && $p[$k] !== '' && $p[$k] !== null )
            $url .= '/(' . $k . ')/' . $p[$k];
    return $url;
};
$stateLinks = array( array( 'name' => '', 'url' => $base( array( 'state' => null ) ), 'current' => !isset( $active['state'] ) ),
                     array( 'name' => 'active', 'url' => $base( array( 'state' => 'active' ) ), 'current' => isset( $active['state'] ) && $active['state'] === 'active' ) );
$counts = expQueue::countBy( 'state', array_diff_key( $filter, array( 'state' => 1 ) ) );
foreach ( expQueueJob::states() as $s )
    $stateLinks[] = array( 'name' => $s, 'url' => $base( array( 'state' => $s ) ), 'current' => isset( $active['state'] ) && $active['state'] === $s,
                           'count' => isset( $counts[$s] ) ? (int) $counts[$s] : 0 );
$classLinks = array( array( 'name' => '', 'url' => $base( array( 'class' => null ) ), 'current' => !isset( $active['class'] ) ) );
foreach ( array_keys( expQueueConfig::instance()->classes() ) as $c )
    $classLinks[] = array( 'name' => $c, 'url' => $base( array( 'class' => $c ) ), 'current' => isset( $active['class'] ) && $active['class'] === $c );

$tpl = eZTemplate::factory();
$tpl->setVariable( 'view', 'list' );
$tpl->setVariable( 'can_manage', expQueueAdmin::canManage() );
$tpl->setVariable( 'flash', expQueueAdmin::takeFlash() );
$tpl->setVariable( 'jobs', array_map( array( 'expQueueAdmin', 'jobRow' ), $jobs ) );
$tpl->setVariable( 'active', $active );
$tpl->setVariable( 'group', $group ? expQueueAdmin::groupRow( $group ) : null );
$tpl->setVariable( 'state_links', $stateLinks );
$tpl->setVariable( 'class_links', $classLinks );
$tpl->setVariable( 'clear_url', 'expqueue/list' );
$tpl->setVariable( 'type_clear_url', $base( array( 'type' => null ) ) );
$tpl->setVariable( 'resource_clear_url', $base( array( 'resource' => null ) ) );
$tpl->setVariable( 'offset', $offset );
$tpl->setVariable( 'limit', $limit );
$tpl->setVariable( 'prev_url', $offset > 0 ? $base( array() ) . ( $offset - $limit > 0 ? '/(offset)/' . ( $offset - $limit ) : '' ) : '' );
$tpl->setVariable( 'next_url', $more ? $base( array() ) . '/(offset)/' . ( $offset + $limit ) : '' );
$tpl->setVariable( 'here', '/' . $base( array() ) . ( $offset ? '/(offset)/' . $offset : '' ) );

$Result = expQueueAdmin::result( 'list', $tpl->fetch( 'design:expqueue/list.tpl' ), array( ezpI18n::tr( 'extension/expqueue', 'Jobs' ) ) );
